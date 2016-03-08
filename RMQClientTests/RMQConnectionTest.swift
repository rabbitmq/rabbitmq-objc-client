import XCTest

class RMQConnectionTest: XCTestCase {

    func startedConnection(
        transport: RMQTransport,
        syncTimeout: Double = 0,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
            return RMQConnection(
                transport: transport,
                user: user,
                password: password,
                vhost: vhost,
                channelMax: 65535,
                frameMax: 131072,
                heartbeat: 0,
                syncTimeout: syncTimeout).start()
    }

    func testHandshaking() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport)
        transport
            .assertClientSentProtocolHeader()
            .serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
            .assertClientSentMethod(MethodFixtures.connectionStartOk(), channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionTune(), channelNumber: 0)
            .assertClientSentMethods([MethodFixtures.connectionTuneOk(), MethodFixtures.connectionOpen()], channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)
    }

    func testClientInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)
        transport.handshake()
        conn.close()

        transport.assertClientSentMethod(
            AMQConnectionClose(
                replyCode: AMQShort(200),
                replyText: AMQShortstr("Goodbye"),
                classId: AMQShort(0),
                methodId: AMQShort(0)
            ),
            channelNumber: 0
        )
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testServerInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport)
        transport.handshake()

        XCTAssertTrue(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelNumber: 0)
    }

    func testCreatingAChannelSendsAChannelOpenAndReceivesOpenOK() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)

        transport.handshake()

        conn.createChannel()

        transport
            .assertClientSentMethod(MethodFixtures.channelOpen(), channelNumber: 1)
            .serverSendsPayload(MethodFixtures.channelOpenOk(), channelNumber: 1)
    }

    func testWaitingOnAServerMessageWithSuccess() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport, syncTimeout: 0.3)

        let halfSecond = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))

        dispatch_after(halfSecond, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport.serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 42)
        }

        try! conn.waitOnMethod(AMQConnectionStart.self, channelNumber: 42)
    }

    func testWaitingOnAServerMethodWithFailure() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport, syncTimeout: 0.1)

        var error: NSError = NSError(domain: "", code: 0, userInfo: [:])
        do {
            try conn.waitOnMethod(AMQConnectionStart.self, channelNumber: 42)
        }
        catch let e as NSError {
            error = e
        }
        catch {
            XCTFail("Wrong error")
        }
        XCTAssertEqual("Timeout", error.localizedDescription)
    }

}
