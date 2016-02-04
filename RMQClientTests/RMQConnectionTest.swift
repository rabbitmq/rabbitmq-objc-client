import XCTest

class RMQConnectionTest: XCTestCase {
    
    func testSendsPreambleToTransport() {
        let transport = FakeTransport().receive(Fixtures.nothing())
        RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport).start()
        XCTAssertEqual("AMQP\0\0\u{09}\u{01}".dataUsingEncoding(NSUTF8StringEncoding), transport.lastWrite())
    }

    func testClosesTransport() {
        let transport = FakeTransport()
            .receive(Fixtures.connectionStart())
            .receive(Fixtures.nothing())
        let conn = RMQConnection(user: "egon", password: "spengler", vhost: "baz", transport: transport).start()

        XCTAssertTrue(transport.isConnected())
        conn.close()
        XCTAssertFalse(transport.isConnected())
    }
    
    func testSendsConnectionStartOK() {
        let transport = FakeTransport()
            .receive(Fixtures.connectionStart())
            .receive(Fixtures.nothing())

        RMQConnection(user: "egon", password: "spengler", vhost: "baz", transport: transport).start()

        let capabilities = AMQFieldTable([
            "publisher_confirms": AMQBoolean(true),
            "consumer_cancel_notify": AMQBoolean(true),
            "exchange_exchange_bindings": AMQBoolean(true),
            "basic.nack": AMQBoolean(true),
            "connection.blocked": AMQBoolean(true),
            "authentication_failure_close": AMQBoolean(true),
            ])
        let clientProperties = AMQFieldTable([
            "capabilities" : capabilities,
            "product"     : AMQLongString("RMQClient"),
            "platform"    : AMQLongString("iOS"),
            "version"     : AMQLongString("0.0.1"),
            "information" : AMQLongString("https://github.com/camelpunch/RMQClient")
        ])
        let startOk = AMQProtocolConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: "PLAIN",
            response: AMQCredentials(username: "egon", password: "spengler"),
            locale: "en_GB"
        )
        let coder = AMQEncoder()
        startOk.encodeWithCoder(coder)
        TestHelper.assertEqualBytes(coder.frameForClassID(10, methodID: 11), actual: transport.lastWrite())
    }
}
