import XCTest

class RMQConnectionRecoverTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: heartbeatSender,
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        recover.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)

        try! q.step()
        XCTAssert(heartbeatSender.stopReceived)
    }

    func testRestartsConnectionAfterConfiguredDelay() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        recover.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)
        XCTAssertEqual(1, q.delayedItems.count)
        XCTAssertEqual(3, q.enqueueDelay)

        try! q.step()

        XCTAssertEqual(1, q.pendingItemsCount(), "Everything after interval must be enqueued in interval enqueue block")
        XCTAssertNil(conn.startCompletionHandler)
        try! q.step()
        XCTAssertNotNil(conn.startCompletionHandler)
    }

    func testRecoversChannelsKeptByAllocator() {
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let conn = StarterSpy()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        let ch0 = allocator.allocate() as! ChannelSpy
        let ch1 = allocator.allocate() as! ChannelSpy
        let ch2 = allocator.allocate() as! ChannelSpy
        let ch3 = allocator.allocate() as! ChannelSpy
        allocator.releaseChannelNumber(2)

        recover.recover(conn, channelAllocator: allocator, error: nil)
        try! q.step()
        try! q.step()

        XCTAssertFalse(ch0.recoverCalled)
        XCTAssertFalse(ch1.recoverCalled)
        XCTAssertFalse(ch2.recoverCalled)
        XCTAssertFalse(ch3.recoverCalled)

        XCTAssertEqual(0, q.pendingItemsCount())
        conn.startCompletionHandler!()

        try! q.step()

        XCTAssertFalse(ch0.recoverCalled)
        XCTAssertFalse(ch2.recoverCalled)

        XCTAssertTrue(ch1.recoverCalled)
        XCTAssertTrue(ch3.recoverCalled)
    }

    func testSendsMessagesToDelegateThroughoutCycle() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: delegate)
        recover.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)
        XCTAssertEqual(conn, delegate.willStartRecoveryConnection!)

        try! q.step()

        XCTAssertNil(delegate.startingRecoveryConnection)

        try! q.step()

        XCTAssertEqual(conn, delegate.startingRecoveryConnection!)
        XCTAssertNil(delegate.recoveredConnection)

        conn.startCompletionHandler!()

        try! q.step()

        XCTAssertEqual(conn, delegate.recoveredConnection!)
    }

    func testDoesNotAttemptRecoveryAfterReachingAttemptLimit() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: delegate)
        recover.recover(nil, channelAllocator: nil, error: nil)
        recover.recover(nil, channelAllocator: nil, error: nil)
        delegate.willStartRecoveryConnection = nil
        let queueLengthBefore = q.items.count

        recover.recover(nil, channelAllocator: nil, error: nil)

        XCTAssertNil(delegate.willStartRecoveryConnection)
        XCTAssertEqual(queueLengthBefore, q.items.count)
    }

    func testAttemptLimitIsResetAfterSuccessfulRecovery() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover.recover(conn, channelAllocator: nil, error: nil)

        try! q.step()                  // stop heartbeats
        try! q.step()                  // attempt connection start, never completes

        recover.recover(conn, channelAllocator: nil, error: nil)

        try! q.step()                  // stop heartbeats
        try! q.step()                  // attempt connection start

        conn.startCompletionHandler!() // this time handshake completes
        try! q.step()                  // run queued after-handshake work

        let queueLengthBefore = q.items.count
        recover.recover(conn, channelAllocator: nil, error: nil)

        XCTAssertGreaterThan(q.items.count, queueLengthBefore)
    }

    func testDoesNotRestartConnectionIfNoErrorAndConfiguredToOnlyRecoverErrors() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: true,
                                           heartbeatSender: heartbeatSender,
                                           commandQueue: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover.recover(conn, channelAllocator: nil, error: nil)

        try! q.step()
        XCTAssert(heartbeatSender.stopReceived)

        XCTAssertEqual(0, q.pendingItemsCount())
    }

    func testRestartsConnectionIfErrorReceivedAndConfiguredToOnlyRecoverErrors() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: true,
                                           heartbeatSender: heartbeatSender,
                                           commandQueue: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover.recover(conn, channelAllocator: nil, error: NSError(domain: RMQErrorDomain, code: 999, userInfo: [:]))

        try! q.step()
        XCTAssert(heartbeatSender.stopReceived)

        try! q.step()
        XCTAssertNotNil(conn.startCompletionHandler)
    }

}
