import XCTest

@objc class FakeFrameHandler : NSObject, RMQFrameHandler {
    var receivedFramesets: [AMQFrameset] = []

    func handleFrameset(frameset: AMQFrameset!) {
        receivedFramesets.append(frameset)
    }

    func lastReceivedFrameset() -> AMQFrameset? {
        return receivedFramesets.last
    }
}

class RMQReaderLoopTest: XCTestCase {

    func testSendsDecodedContentlessFramesetToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FakeFrameHandler()
        let readerLoop = RMQReaderLoop(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.connectionStart()
        let expectedFrameset = AMQFrameset(channelID: 42, method: method, contentHeader: AMQContentHeaderNone(), contentBodies: [])

        readerLoop.runOnce()

        transport.serverSendsPayload(method, channelID: 42)

        XCTAssertEqual(
            expectedFrameset,
            frameHandler.lastReceivedFrameset()!,
            "\n\nExpected: \(method)\n\nGot: \(frameHandler.lastReceivedFrameset()!.method)"
        )
    }
    
    func testSendsDecodedContentFramesetToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FakeFrameHandler()
        let readerLoop = RMQReaderLoop(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk("my.great.queue")
        let body1 = AMQContentBody(data: "aaaaaaa".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentHeader = AMQContentHeader(
            classID: 10,
            bodySize: body1.amqEncoded().length,
            properties: [
                AMQBasicContentType("text/flame")
            ]
        )
        let expectedFrameset = AMQFrameset(channelID: 42, method: method, contentHeader: contentHeader, contentBodies: [body1])

        readerLoop.runOnce()

        transport
            .serverSendsPayload(method, channelID: 42)
            .serverSendsPayload(contentHeader, channelID: 42)
            .serverSendsPayload(body1, channelID: 42)

        XCTAssertEqual(expectedFrameset, frameHandler.lastReceivedFrameset()!)
    }

}
