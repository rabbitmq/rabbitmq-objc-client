import XCTest

class IntegrationTests: XCTestCase {
    
    func testIntegration() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        let frameMaxRequiringTwoFrames = UInt(4096)
        var messageContent = ""
        for _ in 1...(frameMaxRequiringTwoFrames - AMQEmptyFrameSize) {
            messageContent += "a"
        }
        messageContent += "bb"

        let conn = RMQConnection(
            transport: transport,
            idAllocator: RMQChannelIDAllocator(),
            user: "guest",
            password: "guest",
            vhost: "/",
            channelMax: 65535,
            frameMax: frameMaxRequiringTwoFrames,
            heartbeat: 0
        )
        conn.start()
        defer { conn.close() }
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "never connected")

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
    
}
