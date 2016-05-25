import XCTest

class RMQQueueTest: XCTestCase {
    let defaultPropertiesWithPersistence = [RMQBasicContentType("application/octet-stream"),
                                            RMQBasicDeliveryMode(2),
                                            RMQBasicPriority(0)]

    func testPublishSendsBasicPublishToChannel() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)

        queue.publish("a message")

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual(RMQBasicProperties.defaultProperties(), channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithPersistence() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)

        queue.publish("a message", persistent: true)

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual(defaultPropertiesWithPersistence, channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithProperties() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)
        let timestamp = NSDate()

        let properties: [RMQValue] = [
            RMQBasicAppId("some.app"),
            RMQBasicContentEncoding("utf-999"),
            RMQBasicContentType("application.json"),
            RMQBasicCorrelationId("reply2meplz"),
            RMQBasicExpiration("123"),
            RMQBasicMessageId("havdizreplym8"),
            RMQBasicDeliveryMode(2),
            RMQBasicPriority(8),
            RMQBasicReplyTo("some.person"),
            RMQBasicTimestamp(timestamp),
            RMQBasicType("some.type"),
            RMQBasicUserId("my.login"),
            BasicPropertyFixtures.exhaustiveHeaders()
        ]

        queue.publish("a message",
                      properties: properties,
                      options: [.Mandatory])

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([.Mandatory], channel.lastReceivedBasicPublishOptions)
        XCTAssertEqual(properties, channel.lastReceivedBasicPublishProperties!)
    }

    func testPublishWithOptions() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)

        queue.publish("a message", persistent: false, options: [.Immediate, .Mandatory])

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual(RMQBasicProperties.defaultProperties(), channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([.Immediate, .Mandatory], channel.lastReceivedBasicPublishOptions)
    }

    func testPopDelegatesToChannelBasicGet() {
        let stubbedMessage = RMQMessage(consumerTag: "", deliveryTag: 123, content: "hi there")
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel)

        var receivedMessage: RMQMessage?
        queue.pop() { (_, m) in
            receivedMessage = m
        }

        XCTAssertEqual("great.queue", channel.lastReceivedBasicGetQueue)
        XCTAssertEqual([], channel.lastReceivedBasicGetOptions)
        
        channel.lastReceivedBasicGetCompletionHandler!(RMQDeliveryInfo(routingKey: ""), stubbedMessage)
        XCTAssertEqual(stubbedMessage, receivedMessage)
    }

    func testSubscribeSendsABasicConsumeToChannelWithAutoAck() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "default options", channel: channel)

        var handlerCalled = false
        queue.subscribe { (_, _) in
            handlerCalled = true
        }

        let message = RMQMessage(consumerTag: "", deliveryTag: 123, content: "I have default options!")
        channel.lastReceivedBasicConsumeBlock!(RMQDeliveryInfo(routingKey: ""), message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoAck], channel.lastReceivedBasicConsumeOptions)
    }

    func testSubscribeWithOptionsSendsOptionsToChannel() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "custom options", channel: channel)

        var handlerCalled = false
        queue.subscribe([.Exclusive]) { _ in
            handlerCalled = true
        }

        let message = RMQMessage(consumerTag: "", deliveryTag: 123, content: "I have custom options!")
        channel.lastReceivedBasicConsumeBlock!(RMQDeliveryInfo(routingKey: ""), message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.Exclusive], channel.lastReceivedBasicConsumeOptions)
    }

    func testCancellingASubscriptionSendsBasicCancelToChannel() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "cancelling", channel: channel)

        let consumer = queue.subscribe() { _ in }
        XCTAssertNotNil(consumer.tag)

        consumer.cancel()

        XCTAssertEqual(consumer.tag, channel.lastReceivedBasicCancelConsumerTag)
    }

    func testBindCallsBindOnChannel() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = RMQQueue(name: "bindy", channel: channel)

        queue.bind(ex, routingKey: "foo")

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueBindRoutingKey)
    }

    func testBindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = RMQQueue(name: "bindy", channel: channel)

        queue.bind(ex)

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueBindRoutingKey)
    }

    func testUnbindCallsUnbindOnChannel() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = RMQQueue(name: "unbindy", channel: channel)

        queue.unbind(ex, routingKey: "foo")

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueUnbindRoutingKey)
    }
    
    func testUnbindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = RMQQueue(name: "unbindy", channel: channel)

        queue.unbind(ex)

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueUnbindRoutingKey)
    }
    
    func testDeleteCallsDeleteOnChannel() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "deletable", channel: channel)

        queue.delete()
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([], channel.lastReceivedQueueDeleteOptions)

        queue.delete([.IfEmpty])
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([.IfEmpty], channel.lastReceivedQueueDeleteOptions)
    }

}
