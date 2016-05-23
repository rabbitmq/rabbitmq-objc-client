import XCTest

class RMQReaderTest: XCTestCase {

    func testSkipsServerHeartbeats() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.channelOpenOk()
        let expectedFrameset = RMQFrameset(channelNumber: 42, method: method)

        reader.run()

        transport.serverSendsPayload(RMQHeartbeat(), channelNumber: 0)
        transport.serverSendsPayload(method, channelNumber: 42)

        XCTAssertEqual(
            expectedFrameset,
            frameHandler.lastReceivedFrameset()!,
            "\n\nExpected: \(method)\n\nGot: \(frameHandler.lastReceivedFrameset()!.method)"
        )
    }

    func testSendsDecodedContentlessFramesetToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.connectionStart()
        let expectedFrameset = RMQFrameset(channelNumber: 42, method: method)

        reader.run()

        transport.serverSendsPayload(method, channelNumber: 42)

        XCTAssertEqual(
            expectedFrameset,
            frameHandler.lastReceivedFrameset()!,
            "\n\nExpected: \(method)\n\nGot: \(frameHandler.lastReceivedFrameset()!.method)"
        )
    }
    
    func testHandlesContentTerminatedByNonContentFrame() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk("my.great.queue")
        let content1 = RMQContentBody(data: "aa".dataUsingEncoding(NSUTF8StringEncoding)!)
        let content2 = RMQContentBody(data: "bb".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentHeader = RMQContentHeader(
            classID: 10,
            bodySize: 999999,
            properties: [
                RMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = RMQFrameset(
            channelNumber: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )
        let nonContent = nonContentPayload()
        let expectedNonContentFrameset = RMQFrameset(channelNumber: 42, method: nonContent)

        reader.run()

        transport
            .serverSendsPayload(method, channelNumber: 42)
            .serverSendsPayload(contentHeader, channelNumber: 42)
            .serverSendsPayload(content1, channelNumber: 42)
            .serverSendsPayload(content2, channelNumber: 42)
            .serverSendsPayload(nonContent, channelNumber: 42)

        XCTAssertEqual(2, frameHandler.receivedFramesets.count)
        XCTAssertEqual(expectedContentFrameset, frameHandler.receivedFramesets[0])
        XCTAssertEqual(expectedNonContentFrameset, frameHandler.receivedFramesets[1])
    }

    func testHandlesContentTerminatedByEndOfDataSize() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk("my.great.queue")
        let content1 = RMQContentBody(data: "aa".dataUsingEncoding(NSUTF8StringEncoding)!)
        let content2 = RMQContentBody(data: "bb".dataUsingEncoding(NSUTF8StringEncoding)!)
        let contentHeader = RMQContentHeader(
            classID: 10,
            bodySize: content1.amqEncoded().length + content2.amqEncoded().length,
            properties: [
                RMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = RMQFrameset(
            channelNumber: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )

        reader.run()

        transport
            .serverSendsPayload(method, channelNumber: 42)
            .serverSendsPayload(contentHeader, channelNumber: 42)
            .serverSendsPayload(content1, channelNumber: 42)
            .serverSendsPayload(content2, channelNumber: 42)

        XCTAssertEqual([expectedContentFrameset], frameHandler.receivedFramesets)
    }

    func testDeliveryWithZeroBodySizeDoesNotCauseBodyFrameRead() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)

        let deliver = RMQFrame(channelNumber: 42, payload: MethodFixtures.basicDeliver())
        let header = RMQFrame(channelNumber: 42, payload: RMQContentHeader(classID: 60, bodySize: 0, properties: []))

        reader.run()

        transport.serverSendsData(deliver.amqEncoded())

        let before = transport.readCallbacks.count
        transport.serverSendsData(header.amqEncoded())
        let after = transport.readCallbacks.count

        XCTAssertEqual(after, before)
    }

    func testDeliveryWithZeroBodySizeGetsSentToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)

        let method = MethodFixtures.basicDeliver()
        let deliver = RMQFrame(channelNumber: 42, payload: method)
        let header = RMQContentHeader(classID: 60, bodySize: 0, properties: [])
        let headerFrame = RMQFrame(channelNumber: 42, payload: header)

        reader.run()

        transport.serverSendsData(deliver.amqEncoded())
        transport.serverSendsData(headerFrame.amqEncoded())

        XCTAssertEqual(RMQFrameset(channelNumber: 42, method: method, contentHeader: header, contentBodies: []),
                       frameHandler.lastReceivedFrameset())
    }

    func nonContentPayload() -> RMQBasicDeliver {
        return RMQBasicDeliver(consumerTag: RMQShortstr(""), deliveryTag: RMQLonglong(0), options: RMQBasicDeliverOptions.NoOptions, exchange: RMQShortstr(""), routingKey: RMQShortstr("somekey"))
    }
}
