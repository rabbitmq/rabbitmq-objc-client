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
            .serverSends(DataFixtures.connectionStart())
            .clientSends(MethodFixtures.connectionStartOk(), channelID: 0)
            .serverSends(DataFixtures.connectionTune())
            .clientSends(MethodFixtures.connectionTuneOk(), channelID: 0)
            .clientSends(MethodFixtures.connectionOpen(), channelID: 0)
            .serverSends(DataFixtures.connectionOpenOk())

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
        transport.serverSends(DataFixtures.connectionCloseOk())
        XCTAssertFalse(transport.isConnected())
    }

    func testCreatingAChannelSendsAChannelOpenAndReceivesOpenOK() {
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        transport
            .serverSends(DataFixtures.connectionStart())
            .serverSends(DataFixtures.connectionTune())
            .serverSends(DataFixtures.connectionOpenOk())

        let ch = conn.createChannel()
        transport.mustHaveSent(AMQProtocolChannelOpen(reserved1: AMQShortstr("")), channelID: 1, frame: 4)

        XCTAssertFalse(ch.isOpen())
        transport.serverSends(DataFixtures.channelOpenOk())
        XCTAssertTrue(ch.isOpen())
    }
}
