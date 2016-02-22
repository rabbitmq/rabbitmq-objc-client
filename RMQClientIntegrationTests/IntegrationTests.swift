import XCTest

class IntegrationTests: XCTestCase {
    
    func testIntegration() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        let conn = RMQConnection(
            user: "guest",
            password: "guest",
            vhost: "/",
            transport: transport,
            idAllocator: RMQChannelIDAllocator()
        )
        conn.start()
        defer { conn.close() }
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "never connected")

        let ch = conn.createChannel()
        let q = ch.queue("rmqclient.examples.hello_world", autoDelete: true, exclusive: false)
        q.publish("Hello!")
        let message = q.pop() as! RMQContentMessage

        let expectedInfo = ["consumer_tag": "foo"]
        let expectedMeta = ["foo": "bar"]

        let expected = RMQContentMessage(deliveryInfo: expectedInfo, metadata: expectedMeta, content: "Hello!")

        XCTAssertEqual(expected, message)
    }
    
}
