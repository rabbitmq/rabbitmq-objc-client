import XCTest

class RMQConnectionTest: XCTestCase {
    
    func testSendsPreambleToTransport() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        transport.receive(Fixtures().nothing())
        conn.start()
        
        XCTAssertEqual("AMQP\0\0\u{09}\u{01}".dataUsingEncoding(NSUTF8StringEncoding), transport.lastWrite())
    }
    
    func testSendsConnectionStartOK() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "egon", password: "spengler", vhost: "baz", transport: transport)
        
        transport.receive(Fixtures().connectionStart())
        conn.start()
        
        let coder = AMQEncoder()
        let clientProperties = [
            "capabilities" : [
                "type": "field-table",
                "value": [
                    "publisher_confirms": ["type": "boolean", "value": true],
                    "consumer_cancel_notify": ["type": "boolean", "value": true],
                    "exchange_exchange_bindings": ["type": "boolean", "value": true],
                    "basic.nack": ["type": "boolean", "value": true],
                    "connection.blocked": ["type": "boolean", "value": true],
                    "authentication_failure_close": ["type": "boolean", "value": true],
                ]
            ],
            "product"     : ["type": "long-string", "value": "RMQClient"],
            "platform"    : ["type": "long-string", "value": "iOS"],
            "version"     : ["type": "long-string", "value": "0.0.1"],
            "information" : ["type": "long-string", "value": "https://github.com/camelpunch/RMQClient"]]
        
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
