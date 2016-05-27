import XCTest

class RMQConnectionShutdownTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let heartbeatSender = HeartbeatSenderSpy()
        let noRecovery = RMQConnectionShutdown(heartbeatSender: heartbeatSender)
        noRecovery.recover(nil, channelAllocator: nil)
        XCTAssert(heartbeatSender.stopReceived)
    }

}
