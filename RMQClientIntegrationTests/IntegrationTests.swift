import XCTest

class IntegrationTests: XCTestCase {
    
    func testPop() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        let frameMaxRequiringTwoFrames = 4096
        var messageContent = ""
        for _ in 1...(frameMaxRequiringTwoFrames - AMQEmptyFrameSize) {
            messageContent += "a"
        }
        messageContent += "bb"

        let conn = RMQConnection(
            transport: transport,
            user: "guest",
            password: "guest",
            vhost: "/",
            channelMax: 65535,
            frameMax: frameMaxRequiringTwoFrames,
            heartbeat: 0,
            syncTimeout: 10
        )
        conn.start()
        defer { conn.close() }

        let ch = conn.createChannel()
        let qname = "rmqclient.integration-tests.\(NSProcessInfo.processInfo().globallyUniqueString)"
        let q = ch.queue(qname, autoDelete: true, exclusive: false)

        q.publish(messageContent)

        let message = q.pop() as! RMQContentMessage

        let expectedInfo = ["consumer_tag": "foo"]
        let expectedMeta = ["foo": "bar"]

        let expected = RMQContentMessage(
            deliveryInfo: expectedInfo,
            metadata: expectedMeta,
            content: messageContent
        )

        XCTAssertEqual(expected, message)
    }

    func testSubscribe() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        let conn = RMQConnection(
            transport: transport,
            user: "guest",
            password: "guest",
            vhost: "/",
            channelMax: 65535,
            frameMax: 4096,
            heartbeat: 0,
            syncTimeout: 10
        )
        conn.start()
        defer { conn.close() }

        let ch = conn.createChannel()
        let qname = "rmqclient.integration-tests.\(NSProcessInfo.processInfo().globallyUniqueString)"
        let q = ch.queue(qname, autoDelete: true, exclusive: false)

        var delivered = RMQContentMessage(deliveryInfo: [:], metadata: [:], content: "not delivered yet")
        q.subscribe { (message: RMQMessage) in
            delivered = message as! RMQContentMessage
        }

        q.publish("my message")

        XCTAssert(TestHelper.pollUntil { return delivered.content != "not delivered yet" })

        let expectedInfo = ["consumer_tag": "foo"]
        let expectedMeta = ["foo": "bar"]

        let expected = RMQContentMessage(
            deliveryInfo: expectedInfo,
            metadata: expectedMeta,
            content: "my message"
        )

        XCTAssertEqual(expected, delivered)
    }
}
