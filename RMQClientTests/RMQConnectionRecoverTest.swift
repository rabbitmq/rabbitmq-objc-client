import XCTest

class RMQConnectionRecoverTest: XCTestCase {

    func testShutsdownHeartbeatSender() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           connection: conn,
                                           channelAllocator: ChannelSpyAllocator(),
                                           heartbeatSender: heartbeatSender,
                                           commandQueue: q)
        recover.recover()

        try! q.step()
        XCTAssert(heartbeatSender.stopReceived)
    }

    func testRestartsConnectionAfterConfiguredDelay() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let recover = RMQConnectionRecover(interval: 3,
                                           connection: conn,
                                           channelAllocator: ChannelSpyAllocator(),
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q)
        recover.recover()
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
                                           connection: StarterSpy(),
                                           channelAllocator: allocator,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           commandQueue: q)
        let ch0 = allocator.allocate() as! ChannelSpy
        let ch1 = allocator.allocate() as! ChannelSpy
        let ch2 = allocator.allocate() as! ChannelSpy
        let ch3 = allocator.allocate() as! ChannelSpy
        allocator.releaseChannelNumber(2)

        recover.recover()
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

}
