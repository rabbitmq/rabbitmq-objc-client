import XCTest

class RMQConnectionRecoverTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 1,
                                           heartbeatSender: heartbeatSender,
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        recover.recover(conn, channelAllocator: ChannelSpyAllocator())

        try! q.step()
        XCTAssert(heartbeatSender.stopReceived)
    }

    func testRestartsConnectionAfterConfiguredDelay() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        recover.recover(conn, channelAllocator: ChannelSpyAllocator())
        XCTAssertEqual(1, q.delayedItems.count)
        XCTAssertEqual(3, q.enqueueDelay)

        try! q.step()

        XCTAssertEqual(1, q.pendingItemsCount(), "Everything after interval must be enqueued in interval enqueue block")
        XCTAssertFalse(conn.startCalled)
        try! q.step()
        XCTAssert(conn.startCalled)
    }

    func testRecoversChannelsKeptByAllocator() {
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: ConnectionDelegateSpy())
        let ch0 = allocator.allocate() as! ChannelSpy
        let ch1 = allocator.allocate() as! ChannelSpy
        let ch2 = allocator.allocate() as! ChannelSpy
        let ch3 = allocator.allocate() as! ChannelSpy
        allocator.releaseChannelNumber(2)

        recover.recover(StarterSpy(), channelAllocator: allocator)
        try! q.step()
        try! q.step()

        XCTAssertFalse(ch0.recoverCalled)
        XCTAssertFalse(ch1.recoverCalled)
        XCTAssertFalse(ch2.recoverCalled)
        XCTAssertFalse(ch3.recoverCalled)

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
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: delegate)
        recover.recover(conn, channelAllocator: ChannelSpyAllocator())
        XCTAssertEqual(conn, delegate.willStartRecoveryConnection!)

        try! q.step()

        XCTAssertNil(delegate.startingRecoveryConnection)

        try! q.step()

        XCTAssertEqual(conn, delegate.startingRecoveryConnection!)
        XCTAssertNil(delegate.recoveredConnection)

        try! q.step()

        XCTAssertEqual(conn, delegate.recoveredConnection!)
    }

    func testDoesNotAttemptRecoveryAfterReachingAttemptLimit() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q,
                                           delegate: delegate)
        recover.recover(nil, channelAllocator: nil)
        recover.recover(nil, channelAllocator: nil)
        delegate.willStartRecoveryConnection = nil
        let queueLengthBefore = q.items.count

        recover.recover(nil, channelAllocator: nil)

        XCTAssertNil(delegate.willStartRecoveryConnection)
        XCTAssertEqual(queueLengthBefore, q.items.count)
    }

}
