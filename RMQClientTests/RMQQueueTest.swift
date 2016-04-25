import XCTest

class RMQQueueTest: XCTestCase {

    func testPublishSendsBasicPublishToChannel() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel, sender: SenderSpy())

        queue.publish("a message")

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
    }

    func testPublishWithPersistence() {
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "some.queue", channel: channel, sender: SenderSpy())

        queue.publish("a message", persistent: true)

        XCTAssertEqual("a message", channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual(true, channel.lastReceivedBasicPublishPersistent)
    }

    func testPopDelegatesToChannelBasicGet() {
        let sender = SenderSpy()
        let stubbedMessage = RMQMessage(consumerTag: "", deliveryTag: 123, content: "hi there")
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel, sender: sender)

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
        let queue = RMQQueue(name: "default options", channel: channel, sender: SenderSpy())

        var handlerCalled = false
        queue.subscribe { RMQMessage in
            handlerCalled = true
        }

        let message = RMQMessage(consumerTag: "", deliveryTag: 123, content: "I have default options!")
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoAck], channel.lastReceivedBasicConsumeOptions)
    }

    func testSubscribeWithOptionsSendsOptionsToChannel() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "custom options", channel: channel, sender: SenderSpy())

        var handlerCalled = false

        queue.subscribe([.NoWait]) { RMQMessage in
            handlerCalled = true
        }

        let message = RMQMessage(consumerTag: "", deliveryTag: 123, content: "I have custom options!")
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoWait], channel.lastReceivedBasicConsumeOptions)
    }

}
