import XCTest

@objc class FakeFrameHandler : NSObject, RMQFrameHandler {
    var receivedFrames: [AMQFrameset] = []

    func handleFrameset(frameset: AMQFrameset!) {
        receivedFrames.append(frameset)
    }

    func lastReceivedFrame() -> AMQFrameset? {
        return receivedFrames.last
    }
}

class RMQReaderLoopTest: XCTestCase {
    
    func testSendsDecodedFrameToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FakeFrameHandler()
        let readerLoop = RMQReaderLoop(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.connectionStart()
        let expectedFrame = AMQFrameset(typeID: 1, channelID: 42, method: method)

        readerLoop.runOnce()

        transport.serverSendsMethod(method, channelID: 42)

        XCTAssertEqual(expectedFrame, frameHandler.lastReceivedFrame()!)
    }

}
