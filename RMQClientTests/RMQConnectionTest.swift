import XCTest

class RMQConnectionTest: XCTestCase {
    
    func testSendsPreambleToTransport() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        conn.start()
        
        XCTAssertEqual("AMQP\0\0\u{09}\u{01}", transport.lastWrite())
    }
    
    func testSendsConnectionStartOK() {
        let transport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        conn.start()
        transport.receive(Fixtures().connectionStart())
        
        let coder = AMQEncoder()
        let startOk = AMQProtocolConnectionStartOk(
            clientProperties: [
                "capabilities" : [
                    "type": "field-table",
                    "value": [
                        "publisher_confirms": [
                            "type" : "boolean",
                            "value" : true
                        ],
                        "exchange_exchange_bindings": [
                            "type": "boolean",
                            "value": true
                        ],
                        "basic.nack": [
                            "type": "boolean",
                            "value": true
                        ],
                        "consumer_cancel_notify": [
                            "type": "boolean",
                            "value": true
                        ],
                        "connection.blocked": [
                            "type": "boolean",
                            "value": true
                        ],
                        "consumer_priorities": [
                            "type": "boolean",
                            "value": true
                        ],
                        "authentication_failure_close": [
                            "type": "boolean",
                            "value": true
                        ],
                        "per_consumer_qos": [
                            "type": "boolean",
                            "value": true
                        ]
                    ]
                ]
            ],
            mechanism: "PLAIN",
            response: NSData(),
            locale: "en_GB"
            )
        startOk.encodeWithCoder(coder)
        let expectedString = String(data: coder.data, encoding: NSASCIIStringEncoding)!
        XCTAssertEqual(expectedString, transport.lastWrite())
    }
    
}
