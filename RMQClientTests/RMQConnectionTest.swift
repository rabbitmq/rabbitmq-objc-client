import XCTest

class RMQConnectionTest: XCTestCase {

    func startedConnection(
        transport: RMQTransport,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
            let allocator = RMQChannel1Allocator()
            return RMQConnection(
                transport: transport,
                channelAllocator: allocator,
                frameHandler: allocator,
                user: user,
                password: password,
                vhost: vhost,
                channelMax: 65535,
                frameMax: 131072,
                heartbeat: 0
                ).start()
    }

    func testHandshaking() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport)
        transport
            .assertClientSentProtocolHeader()
            .serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
            .assertClientSentMethod(MethodFixtures.connectionStartOk(), channelID: 0)
            .serverSendsPayload(MethodFixtures.connectionTune(), channelID: 0)
            .assertClientSentMethods([MethodFixtures.connectionTuneOk(), MethodFixtures.connectionOpen()], channelID: 0)
            .serverSendsPayload(MethodFixtures.connectionOpenOk(), channelID: 0)
    }

    func testClientInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)
        transport.handshake()
        conn.close()

        transport.assertClientSentMethod(
            AMQProtocolConnectionClose(
                replyCode: AMQShort(200),
                replyText: AMQShortstr("Goodbye"),
                classId: AMQShort(0),
                methodId: AMQShort(0)
            ),
            channelID: 0
        )
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelID: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testServerInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport)
        transport.handshake()

        XCTAssertTrue(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelID: 0)
        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelID: 0)
    }

    func testCreatingAChannelSendsAChannelOpenAndReceivesOpenOK() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)

        transport.handshake()

        conn.createChannel()

        transport
            .assertClientSentMethod(MethodFixtures.channelOpen(), channelID: 1)
            .serverSendsPayload(MethodFixtures.channelOpenOk(), channelID: 1)
    }

    func testWaitingOnAServerMessageWithSuccess() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)

        let halfSecond = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))

        dispatch_after(halfSecond, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport.serverSendsPayload(MethodFixtures.connectionStart(), channelID: 42)
        }

        try! conn.waitOnMethod(AMQProtocolConnectionStart.self, channelID: 42)
    }

    func testWaitingOnAServerMethodWithFailure() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)

        var error: NSError = NSError(domain: "", code: 0, userInfo: [:])
        do {
            try conn.waitOnMethod(AMQProtocolConnectionStart.self, channelID: 42)
        }
        catch let e as NSError {
            error = e
        }
        catch {
            XCTFail("Wrong error")
        }
        XCTAssertEqual("Timeout", error.localizedDescription)
    }

    func testBasicDeliverGetsSentToAllocator() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        RMQConnection(
            transport: transport,
            channelAllocator: RMQChannel1Allocator(),
            frameHandler: frameHandler,
            user: "foo",
            password: "bar",
            vhost: "",
            channelMax: 10,
            frameMax: 5000,
            heartbeat: 10
        ).start()
        transport.handshake()

        let body1 = AMQContentBody(data: "a great ".dataUsingEncoding(NSUTF8StringEncoding)!)
        let body2 = AMQContentBody(data: "message".dataUsingEncoding(NSUTF8StringEncoding)!)
        let header = AMQContentHeader(classID: 123, bodySize: body1.length + body2.length, properties: [])
        transport
            .serverSendsPayload(MethodFixtures.basicDeliver(), channelID: 2)
            .serverSendsPayload(header, channelID: 2)
            .serverSendsPayload(body1, channelID: 2)
            .serverSendsPayload(body2, channelID: 2)

        let expectedMethod = AMQProtocolBasicDeliver(
            consumerTag: AMQShortstr(""),
            deliveryTag: AMQLonglong(0),
            options: AMQProtocolBasicDeliverOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("")
        )

        let expectedFrameset = AMQFrameset(
            channelID: 2,
            method: expectedMethod,
            contentHeader: header,
            contentBodies: [body1, body2]
        )

        XCTAssertEqual(expectedFrameset, frameHandler.receivedFramesets.last)
    }
}
