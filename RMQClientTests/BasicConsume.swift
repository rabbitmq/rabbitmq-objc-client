import XCTest

class BasicConsume: XCTestCase {
    
    func testCarriesServerGeneratedConsumerTagWithBasicConsumeOK() {
        let conn = RMQConnection(
            user: "rmqclient",
            password: "rmqclient_password",
            vhost: "rmqclient_testbed",
            transport: FakeTransport()
        )
        conn.start()
        defer { conn.close() }
        
        let ch = conn.createChannel()
        defer { ch.close() }
        
        let q = ch.queue("", autoDelete: false, exclusive: true)
        
        let consumeOK: AMQProtocolBasicConsumeOk = ch.basicConsume(q)
        
        XCTAssertNotNil(
            consumeOK.consumerTag.rangeOfString(
                "amq\\.ctag.*",
                options: .RegularExpressionSearch
            ), "consumer tag didn't match"
        )
    }
 
    func testAutomaticAcknowledgementMode() {
        let transport: RMQTransport = FakeTransport()
        let conn = RMQConnection(user: "rmqclient", password: "rmqclient_password", vhost: "rmqclient_testbed", transport: transport)
        conn.start()
        
        let ch = conn.createChannel()
        let queueIdx: Int = random() % 10
        let queueName = "rmqclient.basic_consume\(queueIdx)"
        let q = ch.queue(queueName, autoDelete: true, exclusive: false)
        
        ch.basicConsume(q, consumerTag: "", ack: false, exclusive: false) { (deliveryInfo, properties, payload) -> Void in
            
        }
    }
    
}
