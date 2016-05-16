import XCTest

class RMQQueueTest: XCTestCase {

    func testPublishSendsBasicPublishToChannel() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)

        queue.publish("a message")

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
    }

    func testPublishWithPersistence() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel)

        queue.publish("a message", persistent: true)

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual(true, channel.lastReceivedBasicPublishPersistent)
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

        queue.subscribe([.NoWait]) { RMQMessage in
            handlerCalled = true
        }

        let message = RMQMessage(consumerTag: "", deliveryTag: 123, content: "I have custom options!")
        channel.lastReceivedBasicConsumeBlock!(RMQDeliveryInfo(routingKey: ""), message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoWait], channel.lastReceivedBasicConsumeOptions)
    }

    func testBindCallsBindOnChannel() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", channel: channel)
        let queue = RMQQueue(name: "bindy", channel: channel)

        queue.bind(ex, routingKey: "foo")

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueBindRoutingKey)
    }

    func testBindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(123)
        let ex = RMQExchange(name: "my-exchange", channel: channel)
        let queue = RMQQueue(name: "bindy", channel: channel)

        queue.bind(ex)

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueBindRoutingKey)
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
