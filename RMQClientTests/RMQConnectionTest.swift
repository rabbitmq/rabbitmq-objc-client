import XCTest

class RMQConnectionTest: XCTestCase {
    
    func testSendsPreambleToTransport() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        transport.receive(Fixtures.nothing())
        conn.start()
        
        XCTAssertEqual("AMQP\0\0\u{09}\u{01}".dataUsingEncoding(NSUTF8StringEncoding), transport.lastWrite())
    }
    
    func testSendsConnectionStartOK() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "egon", password: "spengler", vhost: "baz", transport: transport)
        
        transport.receive(Fixtures.connectionStart());
        conn.start()
        
        let coder = AMQEncoder()
        let clientProperties = [
            "capabilities" : [
                "publisher_confirms": AMQTrue(),
                "consumer_cancel_notify": AMQTrue(),
                "exchange_exchange_bindings": AMQTrue(),
                "basic.nack": AMQTrue(),
                "connection.blocked": AMQTrue(),
                "authentication_failure_close": AMQTrue(),
            ],
            "product"     : "RMQClient",
            "platform"    : "iOS",
            "version"     : "0.0.1",
            "information" : "https://github.com/camelpunch/RMQClient"
        ]
        
        let startOk = AMQProtocolConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: "PLAIN",
            response: AMQCredentials(username: "egon", password: "spengler"),
            locale: "en_GB"
        )
        startOk.encodeWithCoder(coder)
        TestHelper.assertEqualBytes(coder.frameForClassID(10, methodID: 11), actual: transport.lastWrite())
    }
}
