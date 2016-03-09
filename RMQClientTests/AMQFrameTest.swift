import XCTest

class AMQFrameTest: XCTestCase {
    let heartbeatFrame = AMQFrame(channelNumber: 0, payload: AMQHeartbeat())
    let heartbeatFrameWrongChannel = AMQFrame(channelNumber: 1, payload: AMQHeartbeat())
    let nonHeartbeatFrame = AMQFrame(channelNumber: 0, payload: MethodFixtures.connectionStart())
    
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
