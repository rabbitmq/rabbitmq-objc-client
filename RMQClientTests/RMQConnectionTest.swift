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

        transport
            .clientSendsProtocolHeader()
            .serverSends(Fixtures.connectionStart())
            .clientSends(Fixtures.connectionStartOk(), channelID: 0)
            .serverSends(Fixtures.connectionTune())
            .clientSends(Fixtures.connectionTuneOk(), channelID: 0)
            .clientSends(Fixtures.connectionOpen(), channelID: 0)
            .serverSends(Fixtures.connectionOpenOk())

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
        transport.serverSends(Fixtures.connectionCloseOk())
        XCTAssertFalse(transport.isConnected())
    }

    func testCreatingAChannelSendsAChannelOpenAndReceivesOpenOK() {
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        transport
            .serverSends(Fixtures.connectionStart())
            .serverSends(Fixtures.connectionTune())
            .serverSends(Fixtures.connectionOpenOk())

        let ch = conn.createChannel()
        transport.mustHaveSent(AMQProtocolChannelOpen(reserved1: AMQShortstr("")), channelID: 1, frame: 4)

        XCTAssertFalse(ch.isOpen())
        transport.serverSends(Fixtures.channelOpenOk())
        XCTAssertTrue(ch.isOpen())
    }
}
