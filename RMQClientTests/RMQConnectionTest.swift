import XCTest

class RMQConnectionTest: XCTestCase {

    func startedConnection(
        transport: FakeTransport,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
            return RMQConnection(user: user, password: password, vhost: vhost, transport: transport, idAllocator: RMQChannelIDAllocator()).start()
    }

    func testSendsPreambleToTransport() {
        let transport = FakeTransport()
        startedConnection(transport)
        XCTAssertEqual("AMQP\0\0\u{09}\u{01}".dataUsingEncoding(NSUTF8StringEncoding), transport.sentFrame(0))
    }

    func testClosesTransport() {
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        XCTAssertTrue(transport.isConnected())
        conn.close()
        XCTAssertFalse(transport.isConnected())
    }

    func testClosesConnectionWithHandshake() {
        let transport = FakeTransport()
        let conn = startedConnection(transport)

        conn.close()

        let expectedClose = AMQProtocolConnectionClose(
            replyCode: AMQShort(200),
            replyText: AMQShortstr("Goodbye"),
            classId: AMQShort(0),
            methodId: AMQShort(0)
        )
        transport.mustHaveSent(expectedClose, channelID: 0, frame: transport.lastFrameIndex())
        XCTAssertFalse(transport.isConnected())
    }
    
    func testSendsConnectionStartOK() {
        let transport = FakeTransport()

        startedConnection(transport, user: "egon", password: "spengler", vhost: "hq")

        let capabilities = AMQTable([
            "publisher_confirms": AMQBoolean(true),
            "consumer_cancel_notify": AMQBoolean(true),
            "exchange_exchange_bindings": AMQBoolean(true),
            "basic.nack": AMQBoolean(true),
            "connection.blocked": AMQBoolean(true),
            "authentication_failure_close": AMQBoolean(true),
            ])
        let clientProperties = AMQTable([
            "capabilities" : capabilities,
            "product"     : AMQLongstr("RMQClient"),
            "platform"    : AMQLongstr("iOS"),
            "version"     : AMQLongstr("0.0.1"),
            "information" : AMQLongstr("https://github.com/camelpunch/RMQClient")
        ])
        let startOk = AMQProtocolConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: AMQShortstr("PLAIN"),
            response: AMQCredentials(username: "egon", password: "spengler"),
            locale: AMQShortstr("en_GB")
        )

        transport
            .serverRepliesWith(Fixtures.connectionStart())
            .mustHaveSent(startOk, channelID: 0, frame: 1)
    }

    func testSendsTuneOKFollowedByOpen() {
        let transport = FakeTransport()

        startedConnection(transport)

        let tuneOk = AMQProtocolConnectionTuneOk(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
        let open = AMQProtocolConnectionOpen(virtualHost: AMQShortstr("/"), reserved1: AMQShortstr(""), reserved2: AMQBit(0))

        transport
            .serverRepliesWith(Fixtures.connectionStart())
            .serverRepliesWith(Fixtures.connectionTune())

        transport
            .mustHaveSent(tuneOk, channelID: 0, frame: 2)
            .mustHaveSent(open, channelID: 0, frame: 3)
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
