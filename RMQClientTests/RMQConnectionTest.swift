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

    func testConnectionHandshaking() {
        let transport = ControlledInteractionTransport()

        startedConnection(transport)

        transport
            .clientSendsProtocolHeader()
            .serverRepliesWith(Fixtures.connectionStart())
            .clientSends(Fixtures.connectionStartOk(), channelID: 0)
            .serverRepliesWith(Fixtures.connectionTune())
            .clientSends(Fixtures.connectionTuneOk(), channelID: 0)
            .clientSends(Fixtures.connectionOpen(), channelID: 0)
    }

    func testClosesConnectionWithHandshake() {
        let transport = ControlledInteractionTransport()
        let conn = startedConnection(transport)

        transport
            .clientSendsProtocolHeader()
            .serverRepliesWith(Fixtures.connectionStart())
            .clientSends(Fixtures.connectionStartOk(), channelID: 0)
            .serverRepliesWith(Fixtures.connectionTune())
            .clientSends(Fixtures.connectionTuneOk(), channelID: 0)
            .clientSends(Fixtures.connectionOpen(), channelID: 0)
            .serverRepliesWith(Fixtures.connectionOpenOk())

        conn.close()

        transport.clientSends(
            AMQProtocolConnectionClose(
                replyCode: AMQShort(200),
                replyText: AMQShortstr("Goodbye"),
                classId: AMQShort(0),
                methodId: AMQShort(0)
            ),
            channelID: 0
        )
        XCTAssert(transport.isConnected())
        transport.serverRepliesWith(Fixtures.connectionCloseOk())
        XCTAssertFalse(transport.isConnected())
    }

    func testCreatingAChannelSendsAChannelOpenAndReceivesOpenOK() {
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        transport
            .serverRepliesWith(Fixtures.connectionStart())
            .serverRepliesWith(Fixtures.connectionTune())
            .serverRepliesWith(Fixtures.connectionOpenOk())

        let ch = conn.createChannel()
        transport.mustHaveSent(AMQProtocolChannelOpen(reserved1: AMQShortstr("")), channelID: 1, frame: 4)

        XCTAssertFalse(ch.isOpen())
        transport.serverRepliesWith(Fixtures.channelOpenOk())
        XCTAssertTrue(ch.isOpen())
    }
}
