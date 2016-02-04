import XCTest

class IntegrationTests: XCTestCase {
    
    func testIntegration() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        let conn = RMQConnection(
            user: "guest",
            password: "guest",
            vhost: "/",
            transport: transport
        )
        conn.start()
        defer { conn.close() }
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "never connected")

        conn.createChannel()
//        let ch = conn.createChannel()
//        let q = ch.queue("rmqclient.examples.hello_world", autoDelete: true, exclusive: false)
//        let x = ch.defaultExchange()
//
//        let expectedInfo = ["consumer_tag": "foo"]
//        let expectedMeta = ["foo": "bar"]
//        let expectedPayload = ["baz": "qux"]
//
//        var responseReceived = false
//        q.subscribe { (info, meta, p) -> Void in
//            if NSDictionary(dictionary: info).isEqualToDictionary(expectedInfo) &&
//                NSDictionary(dictionary: meta).isEqualToDictionary(expectedMeta) &&
//                NSDictionary(dictionary: p).isEqualToDictionary(expectedPayload) {
//                    responseReceived = true
//            } else {
//                XCTFail("subscribe response unexpected")
//            }
//        }
//        
//        x.publish("Hello!", routingKey: q.name)
//
//        XCTAssert(TestHelper.pollUntil { return responseReceived }, "didn't receive message")
    }
    
}
