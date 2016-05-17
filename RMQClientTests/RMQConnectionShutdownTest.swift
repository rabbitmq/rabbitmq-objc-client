import XCTest

class RMQConnectionShutdownTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let heartbeatSender = HeartbeatSenderSpy()
        let noRecovery = RMQConnectionShutdown(connection: StarterSpy(),
                                               channelAllocator: ChannelSpyAllocator(),
                                               heartbeatSender: heartbeatSender)
        noRecovery.recover()
        XCTAssert(heartbeatSender.stopReceived)
    }

    func testDoesNotRestartConnection() {
        let conn = StarterSpy()
        let noRecovery = RMQConnectionShutdown(connection: conn,
                                               channelAllocator: ChannelSpyAllocator(),
                                               heartbeatSender: HeartbeatSenderSpy())
        noRecovery.recover()
        XCTAssertFalse(conn.startCalled)
    }

    func testDoesNotRecoverChannels() {
        let allocator = ChannelSpyAllocator()
        allocator.allocate()
        allocator.allocate()
        let shutdown = RMQConnectionShutdown(connection: StarterSpy(),
                                             channelAllocator: allocator,
                                             heartbeatSender: HeartbeatSenderSpy())
        shutdown.recover()
        XCTAssertFalse(allocator.channels[0].recoverCalled)
        XCTAssertFalse(allocator.channels[1].recoverCalled)
    }

}
