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

        XCTAssertFalse(conn.startCalled)
        try! q.step()
        XCTAssert(conn.startCalled)
    }

}
