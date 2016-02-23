import XCTest

class RMQConnectionTest: XCTestCase {

    func startedConnection(
        transport: RMQTransport,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
            return RMQConnection(
                user: user,
                password: password,
                vhost: vhost,
                transport: transport,
                idAllocator: RMQChannelIDAllocator()
                ).start()
    }

    func testHandshakingAndClientInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)
        transport.assertHandshake()
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
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        transport
            .serverSends(DataFixtures.connectionStart())
            .serverSends(DataFixtures.connectionTune())
            .serverSends(DataFixtures.connectionOpenOk())

        conn.createChannel()
        transport.mustHaveSent(AMQProtocolChannelOpen(reserved1: AMQShortstr("")), channelID: 1, frame: 4)

        transport.serverSends(DataFixtures.channelOpenOk())
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
}
