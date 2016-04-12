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

    func testPopDelegatesToChannelBasicGet() {
        let sender = SenderSpy()
        let stubbedMessage = RMQContentMessage(consumerTag: "", deliveryTag: 123, content: "hi there")
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel, sender: sender)

        var receivedMessage: RMQContentMessage?
        queue.pop() { m in
            receivedMessage = m as? RMQContentMessage
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

        let message = RMQContentMessage(consumerTag: "", deliveryTag: 123, content: "I have default options!")
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

        let message = RMQContentMessage(consumerTag: "", deliveryTag: 123, content: "I have custom options!")
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoWait], channel.lastReceivedBasicConsumeOptions)
    }

}
