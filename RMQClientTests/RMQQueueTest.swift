import XCTest

class RMQQueueTest: XCTestCase {
    func testPublishSendsBasicPublishToChannel() {
        let channel = ChannelSpy(42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        queue.publish("a message")

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithPersistence() {
        let channel = ChannelSpy(42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        queue.publish("a message", persistent: true)

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([RMQBasicDeliveryMode(2)], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithProperties() {
        let channel = ChannelSpy(42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")
        let timestamp = NSDate()

        let properties: [RMQValue] = [
            RMQBasicAppId("some.app"),
            RMQBasicContentEncoding("utf-999"),
            RMQBasicContentType("application/json"),
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

        queue.publish("{\"a\": \"message\"}",
                      properties: properties,
                      options: [.Mandatory])

        XCTAssertEqual("{\"a\": \"message\"}", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([.Mandatory], channel.lastReceivedBasicPublishOptions)
        XCTAssertEqual(properties, channel.lastReceivedBasicPublishProperties!)
    }

    func testPublishWithOptions() {
        let channel = ChannelSpy(42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        queue.publish("a message", persistent: false, options: [.Mandatory])

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([.Mandatory], channel.lastReceivedBasicPublishOptions)
    }

    func testPopDelegatesToChannelBasicGet() {
        let stubbedMessage = RMQMessage(content: "hi there", consumerTag: "", deliveryTag: 123, redelivered: false, exchangeName: "", routingKey: "", properties: [])
        let channel = ChannelSpy(42)
        let queue = QueueHelper.makeQueue(channel, name: "great.queue")

        var receivedMessage: RMQMessage?
        queue.pop() { m in
            receivedMessage = m
        }

        XCTAssertEqual("great.queue", channel.lastReceivedBasicGetQueue)
        XCTAssertEqual([], channel.lastReceivedBasicGetOptions)
        
        channel.lastReceivedBasicGetCompletionHandler!(stubbedMessage)
        XCTAssertEqual(stubbedMessage, receivedMessage)
    }

    func testSubscribeSendsABasicConsumeToChannelWithAutoAck() {
        let channel = ChannelSpy(123)
        let queue = QueueHelper.makeQueue(channel, name: "default options")

        var handlerCalled = false
        queue.subscribe { _ in
            handlerCalled = true
        }

        let message = RMQMessage(content: "I have default options!", consumerTag: "", deliveryTag: 123, redelivered: false, exchangeName: "", routingKey: "", properties: [])
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoAck], channel.lastReceivedBasicConsumeOptions)
    }

    func testSubscribeWithOptionsSendsOptionsToChannel() {
        let channel = ChannelSpy(123)
        let queue = QueueHelper.makeQueue(channel, name: "custom options")

        var handlerCalled = false
        queue.subscribe([.Exclusive]) { _ in
            handlerCalled = true
        }

        let message = RMQMessage(content: "I have custom options!", consumerTag: "", deliveryTag: 123, redelivered: false, exchangeName: "", routingKey: "", properties: [])
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.Exclusive], channel.lastReceivedBasicConsumeOptions)
    }

    func testCancellingASubscriptionSendsBasicCancelToChannel() {
        let channel = ChannelSpy(123)
        let queue = QueueHelper.makeQueue(channel, name: "cancelling")

        let consumer = queue.subscribe() { _ in }
        XCTAssertNotNil(consumer.tag)

        consumer.cancel()

        XCTAssertEqual(consumer.tag, channel.lastReceivedBasicCancelConsumerTag)
    }

    func testBindCallsBindOnChannel() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = QueueHelper.makeQueue(channel, name: "bindy")

        queue.bind(ex, routingKey: "foo")

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueBindRoutingKey)
    }

    func testBindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = QueueHelper.makeQueue(channel, name: "bindy")

        queue.bind(ex)

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueBindRoutingKey)
    }

    func testUnbindCallsUnbindOnChannel() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = QueueHelper.makeQueue(channel, name: "unbindy")

        queue.unbind(ex, routingKey: "foo")

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueUnbindRoutingKey)
    }
    
    func testUnbindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)
        let queue = QueueHelper.makeQueue(channel, name: "unbindy")

        queue.unbind(ex)

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueUnbindRoutingKey)
    }
    
    func testDeleteCallsDeleteOnChannel() {
        let channel = ChannelSpy(123)
        let queue = QueueHelper.makeQueue(channel, name: "deletable")

        queue.delete()
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([], channel.lastReceivedQueueDeleteOptions)

        queue.delete([.IfEmpty])
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([.IfEmpty], channel.lastReceivedQueueDeleteOptions)
    }

}
