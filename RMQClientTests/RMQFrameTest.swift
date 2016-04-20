import XCTest

class RMQFrameTest: XCTestCase {
    let heartbeatFrame = RMQFrame(channelNumber: 0, payload: RMQHeartbeat())
    let heartbeatFrameWrongChannel = RMQFrame(channelNumber: 1, payload: RMQHeartbeat())
    let nonHeartbeatFrame = RMQFrame(channelNumber: 0, payload: MethodFixtures.connectionStart())
    
    func testHeartbeatFrameChannelZeroIsAHeartbeat() {
        XCTAssert(heartbeatFrame.isHeartbeat())
    }

    func testHeartbeatFrameOtherChannelIsNotAHeartbeat() {
        XCTAssertFalse(heartbeatFrameWrongChannel.isHeartbeat())
    }

    func testNonHeartbeatFrameIsNotAHeartBeat() {
        XCTAssertFalse(nonHeartbeatFrame.isHeartbeat())
    }

}
