import XCTest

class RMQReaderLoopTest: XCTestCase {

    func testSendsDecodedContentlessFramesetToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
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
    
    func testHandlesContentTerminatedByNonContentFrame() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let readerLoop = RMQReaderLoop(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk("my.great.queue")
        let content1 = AMQContentBody(data: "aa".dataUsingEncoding(NSUTF8StringEncoding)!)
        let content2 = AMQContentBody(data: "bb".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentHeader = AMQContentHeader(
            classID: 10,
            bodySize: 999999,
            properties: [
                AMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = AMQFrameset(
            channelID: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )
        let nonContent = nonContentPayload()
        let expectedNonContentFrameset = AMQFrameset(
            channelID: 42,
            method: nonContent,
            contentHeader: AMQContentHeaderNone(),
            contentBodies: []
        )

        readerLoop.runOnce()

        transport
            .serverSendsPayload(method, channelID: 42)
            .serverSendsPayload(contentHeader, channelID: 42)
            .serverSendsPayload(content1, channelID: 42)
            .serverSendsPayload(content2, channelID: 42)
            .serverSendsPayload(nonContent, channelID: 42)

        XCTAssertEqual(2, frameHandler.receivedFramesets.count)
        XCTAssertEqual(expectedContentFrameset, frameHandler.receivedFramesets[0])
        XCTAssertEqual(expectedNonContentFrameset, frameHandler.receivedFramesets[1])
    }

    func testHandlesContentTerminatedByEndOfDataSize() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let readerLoop = RMQReaderLoop(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk("my.great.queue")
        let content1 = AMQContentBody(data: "aa".dataUsingEncoding(NSUTF8StringEncoding)!)
        let content2 = AMQContentBody(data: "bb".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentHeader = AMQContentHeader(
            classID: 10,
            bodySize: content1.amqEncoded().length + content2.amqEncoded().length,
            properties: [
                AMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = AMQFrameset(
            channelID: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )

        readerLoop.runOnce()

        transport
            .serverSendsPayload(method, channelID: 42)
            .serverSendsPayload(contentHeader, channelID: 42)
            .serverSendsPayload(content1, channelID: 42)
            .serverSendsPayload(content2, channelID: 42)

        XCTAssertEqual([expectedContentFrameset], frameHandler.receivedFramesets)
    }

    func nonContentPayload() -> AMQProtocolBasicDeliver {
        return AMQProtocolBasicDeliver(consumerTag: AMQShortstr(""), deliveryTag: AMQLonglong(0), options: AMQProtocolBasicDeliverOptions.NoOptions, exchange: AMQShortstr(""), routingKey: AMQShortstr("somekey"))
    }
}
