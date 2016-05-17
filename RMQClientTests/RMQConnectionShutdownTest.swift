import XCTest

class RMQConnectionShutdownTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let heartbeatSender = HeartbeatSenderSpy()
        let noRecovery = RMQConnectionShutdown(heartbeatSender: heartbeatSender)
        noRecovery.recover()
        XCTAssert(heartbeatSender.stopReceived)
    }

}
