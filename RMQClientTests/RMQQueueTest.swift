import XCTest

class RMQQueueTest: XCTestCase {

    func testPublishSendsABasicPublish() {
        let sender = SenderSpy(frameMax: 4 + AMQEmptyFrameSize)
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "my.q", channel: channel, sender: sender)
        let messageContent = "my great message yo"

        queue.publish(messageContent)

        let publish = AMQBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQBasicPublishOptions.NoOptions
        )
        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!

        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let expectedBodies = [
            AMQContentBody(data: "my g".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "reat".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " mes".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "sage".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " yo".dataUsingEncoding(NSUTF8StringEncoding)!),
        ]

        let expectedFrameset = AMQFrameset(
            channelNumber: 123,
            method: publish,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        XCTAssertEqual(5, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let sender = SenderSpy(frameMax: 4 + AMQEmptyFrameSize)
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "my.q", channel: channel, sender: sender)
        let messageContent = "12345678"

        queue.publish(messageContent)

        let expectedMethod = AMQBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQBasicPublishOptions.NoOptions
        )

        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!
        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let expectedBodies = [
            AMQContentBody(data: "1234".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "5678".dataUsingEncoding(NSUTF8StringEncoding)!),
        ]

        let expectedFrameset = AMQFrameset(
            channelNumber: 123,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        XCTAssertEqual(2, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }
    
    func testPopSendsAGet() {
        let sender = SenderSpy()
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel, sender: sender)

        queue.pop()

        let get = AMQBasicGet(
            reserved1: AMQShort(0),
            queue: AMQShortstr("great.queue"),
            options: AMQBasicGetOptions.NoOptions
        )
        let expectedFrameset = AMQFrameset(channelNumber: 42, method: get)

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testPopWaitsOnNextGetOk() {
        let sender = SenderSpy()
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel, sender: sender)

        queue.pop()

        XCTAssertEqual("AMQBasicGetOk", sender.methodWaitedUpon)
        XCTAssertEqual(42, sender.channelWaitedUpon)
    }

    func testPopReturnsMessageBasedOnLastFramesetWaitedUpon() {
        let sender = SenderSpy()
        let channel = ChannelSpy(42)
        let queue = RMQQueue(name: "great.queue", channel: channel, sender: sender)

        let method = AMQBasicGetOk(
            deliveryTag: AMQLonglong(0),
            options: AMQBasicGetOkOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr(""),
            messageCount: AMQLong(0)
        )
        let header = AMQContentHeader(classID: 123, bodySize: 321, properties: [])
        let body1 = AMQContentBody(data: "totally expected ".dataUsingEncoding(NSUTF8StringEncoding)!)
        let body2 = AMQContentBody(data: "message".dataUsingEncoding(NSUTF8StringEncoding)!)

        sender.lastWaitedUponFrameset = AMQFrameset(
            channelNumber: 42,
            method: method,
            contentHeader: header,
            contentBodies: [body1, body2]
        )

        XCTAssertEqual("totally expected message", queue.pop().content)
    }

    func testSubscribeSendsABasicConsumeToChannelWithAutoAck() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(name: "default options", channel: channel, sender: SenderSpy())

        var handlerCalled = false
        try! queue.subscribe { RMQMessage in
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

        try! queue.subscribe([.NoWait]) { RMQMessage in
            handlerCalled = true
        }

        let message = RMQContentMessage(consumerTag: "", deliveryTag: 123, content: "I have custom options!")
        channel.lastReceivedBasicConsumeBlock!(message)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.NoWait], channel.lastReceivedBasicConsumeOptions)
    }

    func testBasicConsumeErrorsArePropagatedThroughSubscribe() {
        let channel = ChannelSpy(123)
        channel.throwFromBasicConsume = true
        let queue = RMQQueue(name: "custom options", channel: channel, sender: SenderSpy())

        do {
            try queue.subscribe { RMQMessage in }
        }
        catch let e as NSError {
            XCTAssertEqual("RMQClientTests.ChannelSpyError", e.domain)
        }
        catch {
            XCTFail("Wrong error")
        }
    }

    func testGettingMessageCountRedeclaresQueueWithSameOptions() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(
            name: "my great queue",
            options: [.AutoDelete, .Durable],
            channel: channel,
            sender: SenderSpy()
        )

        queue.messageCount()

        let expectedOptions: AMQQueueDeclareOptions = [.AutoDelete, .Durable]
        XCTAssertEqual(expectedOptions, channel.lastReceivedQueueDeclareOptions)
    }

    func testMessageCountRetrievedFromQueueDeclareOk() {
        let channel = ChannelSpy(123)
        channel.stubbedMessageCount = AMQLong(666)
        let queue = RMQQueue(name: "my great queue", channel: channel, sender: SenderSpy())

        XCTAssertEqual(666, queue.messageCount())
    }

    func testGettingConsumerCountRedeclaresQueueWithSameOptions() {
        let channel = ChannelSpy(123)
        let queue = RMQQueue(
            name: "my great queue",
            options: [.AutoDelete, .Durable],
            channel: channel,
            sender: SenderSpy()
        )

        queue.consumerCount()

        let expectedOptions: AMQQueueDeclareOptions = [.AutoDelete, .Durable]
        XCTAssertEqual(expectedOptions, channel.lastReceivedQueueDeclareOptions)
    }

    func testConsumerCountRetrievedFromQueueDeclareOk() {
        let channel = ChannelSpy(321)
        channel.stubbedConsumerCount = AMQLong(444)
        let queue = RMQQueue(name: "marvelous-mechanical-mouse-organ", channel: channel, sender: SenderSpy())

        XCTAssertEqual(444, queue.consumerCount())
    }
}
