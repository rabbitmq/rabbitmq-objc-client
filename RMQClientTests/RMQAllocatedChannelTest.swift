import XCTest

class RMQAllocatedChannelTest: XCTestCase {
    var waiter: FramesetWaiterSpy?

    override func setUp() {
        waiter = FramesetWaiterSpy()
    }

    func testObeysContract() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: dispatch_get_main_queue())
        let contract = RMQChannelContract(channel)

        contract.check()
    }

    func testSuspendsDispatchQueueAndResumesOnActivation() {
        let q = QueueHelper()

        let ch = RMQAllocatedChannel(1, sender: SenderSpy(), waiter: waiter!, queue: q.dispatchQueue)
        var called = false
        dispatch_async(q.dispatchQueue) { called = true }

        XCTAssertFalse(called)

        ch.activateWithDelegate(nil)
        q.suspend().finish()

        XCTAssertTrue(called)
    }

    func testIncomingSyncFramesetsAreSentToWaiter() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let frameset = AMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        ch.activateWithDelegate(nil)
        q.suspend()

        ch.handleFrameset(frameset)

        XCTAssertEqual(frameset, waiter?.lastFulfilledFrameset)
    }

    func testOpeningSendsAChannelOpen() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let openOk = AMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)

        ch.activateWithDelegate(delegate)
        q.suspend()

        ch.open()
        XCTAssert(sender.sentFramesets.isEmpty, "Something was sent prematurely!")

        ch.handleFrameset(openOk)
        q.finish()

        XCTAssertEqual(
            AMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()),
            sender.sentFramesets.last!
        )

        XCTAssertNil(delegate.lastChannelOpenError)
    }

    func testOpeningFailsIfWaitFails() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        ch.activateWithDelegate(delegate)
        q.suspend()

        ch.open()

        waiter?.err("foo")
        q.finish()

        XCTAssertEqual("foo", delegate.lastChannelOpenError!.localizedDescription)
    }

    func testQueueSendsAQueueDeclareWithNoWait() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)

        ch.queue("bagpuss")

        XCTAssertEqual(0, sender.sentFramesets.count)
        q.finish()

        let expectedQueueDeclare = AMQQueueDeclare(
            reserved1: AMQShort(0),
            queue: AMQShortstr("bagpuss"),
            options: [.NoWait],
            arguments: AMQTable([:])
        )
        let actualFrame = sender.sentFramesets.last!
        let actualMethod = actualFrame.method as! AMQQueueDeclare
        XCTAssertEqual(expectedQueueDeclare, actualMethod)
    }

    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        let expectedMethod = AMQBasicConsume(
            reserved1: AMQShort(0),
            queue: AMQShortstr("a_queue_name"),
            consumerTag: AMQShortstr(""),
            options: [.NoAck],
            arguments: AMQTable([:])
        )

        q.suspend()

        channel.basicConsume("a_queue_name", options: [.NoAck]) { message in }
        XCTAssertNil(sender.lastSentMethod)

        waiter!.fulfill(AMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("heres-ur-tag-bro")))
        q.finish()
        let receivedMethod = sender.lastSentMethod! as! AMQBasicConsume
        XCTAssertEqual(expectedMethod, receivedMethod)
    }

    func testBasicConsumeSendsErrorToDelegateOnWaitError() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()

        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(delegate)

        q.suspend()

        channel.basicConsume("a_queue_name", options: []) { message in
            XCTFail("Should not be called")
        }

        waiter!.err("fooey")
        q.finish()

        XCTAssertEqual("fooey", delegate.lastChannelError?.localizedDescription)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let consumeOkMethod = AMQBasicConsumeOk(consumerTag: AMQShortstr("servergeneratedtag"))
        let consumeOkFrameset = AMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: "servergeneratedtag", deliveryTag: 123)
        let deliverHeader = AMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = AMQContentBody(data: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset = AMQFrameset(channelNumber: 432, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
        let expectedMessage = RMQContentMessage(consumerTag: "servergeneratedtag", deliveryTag: 123, content: "Consumed!")

        channel.activateWithDelegate(nil)

        var consumedMessage: RMQContentMessage?
        channel.basicConsume("somequeue", options: []) { message in
            consumedMessage = message as? RMQContentMessage
        }
        channel.handleFrameset(consumeOkFrameset)
        q.suspend().finish()

        XCTAssertNil(consumedMessage)
        channel.handleFrameset(deliverFrameset)
        q.finish()
        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicGetSendsBasicGet() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        ch.activateWithDelegate(nil)
        q.suspend()

        ch.basicGet("my-q", options: [.NoAck]) { _ in }

        XCTAssertEqual(0, sender.sentFramesets.count)

        q.finish()

        let expected = AMQFrameset(channelNumber: 1, method: MethodFixtures.basicGet("my-q", options: [.NoAck]))
        let actual = sender.sentFramesets.last!
        XCTAssertEqual(expected, actual)
    }

    func testBasicGetCallsCompletionHandlerWithMessage() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let getOkFrameset = AMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicGetOk("my-q", deliveryTag: 1),
            contentHeader: AMQContentHeader(classID: 60, bodySize: 123, properties: []),
            contentBodies: [AMQContentBody(data: "hello".dataUsingEncoding(NSUTF8StringEncoding)!)]
        )
        let expectedMessage = RMQContentMessage(consumerTag: "", deliveryTag: 1, content: "hello")
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        ch.activateWithDelegate(nil)

        var receivedMessage: RMQContentMessage?
        ch.basicGet("my-q", options: [.NoAck]) { m in
            receivedMessage = m as? RMQContentMessage
        }
        ch.handleFrameset(getOkFrameset)

        q.suspend().finish()

        ch.handleFrameset(getOkFrameset)

        XCTAssertEqual(expectedMessage, receivedMessage)
    }

    func testBasicGetSendsErrorToDelegateOnWaitError() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()

        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(delegate)

        q.suspend()
        channel.basicGet("naughty-q", options: []) { _ in
            XCTFail("Should not be called")
        }

        waiter!.err("oh no!")
        q.finish()

        XCTAssertEqual("oh no!", delegate.lastChannelError?.localizedDescription)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, queue: q.dispatchQueue)
        let consumeOkFrameset1 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag1")))
        let consumeOkFrameset2 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag2")))
        let deliverMethod1 = MethodFixtures.basicDeliver(consumerTag: "servertag1", deliveryTag: 1)
        let deliverHeader1 = AMQContentHeader(classID: deliverMethod1.classID(), bodySize: 123, properties: [])
        let deliverBody1 = AMQContentBody(data: "A message for consumer 1".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset1 = AMQFrameset(channelNumber: 999, method: deliverMethod1, contentHeader: deliverHeader1, contentBodies: [deliverBody1])
        let deliverMethod2 = MethodFixtures.basicDeliver(consumerTag: "servertag2", deliveryTag: 1)
        let deliverHeader2 = AMQContentHeader(classID: deliverMethod2.classID(), bodySize: 123, properties: [])
        let deliverBody2 = AMQContentBody(data: "A message for consumer 2".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset2 = AMQFrameset(channelNumber: 999, method: deliverMethod2, contentHeader: deliverHeader2, contentBodies: [deliverBody2])
        let expectedMessage1 = RMQContentMessage(consumerTag: "servertag1", deliveryTag: 1, content: "A message for consumer 1")
        let expectedMessage2 = RMQContentMessage(consumerTag: "servertag2", deliveryTag: 1, content: "A message for consumer 2")

        ch.activateWithDelegate(nil)
        q.suspend()

        var consumedMessage1: RMQContentMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage1 = message as? RMQContentMessage
        }
        ch.handleFrameset(consumeOkFrameset1)
        q.finish()

        var consumedMessage2: RMQContentMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage2 = message as? RMQContentMessage
        }
        ch.handleFrameset(consumeOkFrameset2)
        q.finish()

        ch.handleFrameset(deliverFrameset1)
        ch.handleFrameset(deliverFrameset2)
        q.finish()

        XCTAssertEqual(expectedMessage1, consumedMessage1)
        XCTAssertEqual(expectedMessage2, consumedMessage2)
    }

    func testBasicPublishSendsFramesetToSenderOnOwnQueue() {
        let sender = SenderSpy(frameMax: 4 + AMQEmptyFrameSize)
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let message = "my great message yo"
        let persistent = AMQBasicDeliveryMode(2)

        let expectedMethod = AMQBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQBasicPublishOptions.NoOptions
        )
        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: message.dataUsingEncoding(NSUTF8StringEncoding)!.length,
            properties: [persistent, AMQBasicContentType("application/octet-stream"), AMQBasicPriority(0)]
        )
        let expectedBodies = [
            AMQContentBody(data: "my g".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "reat".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " mes".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "sage".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " yo".dataUsingEncoding(NSUTF8StringEncoding)!),
            ]
        let expectedFrameset = AMQFrameset(
            channelNumber: 999,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        ch.activateWithDelegate(nil)
        q.suspend()

        ch.basicPublish(message, routingKey: "my.q", exchange: "")

        XCTAssertEqual(0, sender.sentFramesets.count)

        q.finish()

        XCTAssertEqual(5, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let sender = SenderSpy(frameMax: 4 + AMQEmptyFrameSize)
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let messageContent = "12345678"
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
            channelNumber: 999,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicPublish(messageContent, routingKey: "my.q", exchange: "")

        q.finish()

        XCTAssertEqual(2, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testBasicQosSendsBasicQosGlobal() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicQos(32, global: true)

        XCTAssertNil(sender.lastSentMethod)

        q.finish()

        let expectedMethod = MethodFixtures.basicQos(32, options: [.Global])
        let actualMethod = sender.lastSentMethod as! AMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosSendsBasicQosNonGlobal() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicQos(32, global: false)

        XCTAssertNil(sender.lastSentMethod)

        q.finish()

        let expectedMethod = MethodFixtures.basicQos(32, options: [])
        let actualMethod = sender.lastSentMethod as! AMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosWaitsOnBasicQosOk() {
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicQos(64, global: false)

        q.finish()

        XCTAssertEqual(AMQBasicQosOk.self.description(), waiter?.lastWaitedOnClass!.description())
    }

    func testBasicQosSendsErrorToDelegateOnWaitError() {
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let channel = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(delegate)
        q.suspend()

        channel.basicQos(64, global: false)

        waiter?.err("bad stuff")
        q.finish()

        XCTAssertEqual("bad stuff", delegate.lastChannelError?.localizedDescription)
    }

    func testAckSendsABasicAck() {
        let sender = SenderSpy()
        let q = QueueHelper()

        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.ack(123, options: [.Multiple])

        XCTAssertEqual(0, sender.sentFramesets.count)

        q.finish()

        let expected = AMQBasicAck(deliveryTag: AMQLonglong(123), options: [.Multiple])
        let actual: AMQBasicAck = sender.lastSentMethod as! AMQBasicAck
        XCTAssertEqual(expected, actual)
    }

    func testRejectSendsABasicReject() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.reject(123, options: [.Requeue])

        XCTAssertEqual(0, sender.sentFramesets.count)

        q.finish()

        let expected = AMQBasicReject(deliveryTag: AMQLonglong(123), options: [.Requeue])
        let actual: AMQBasicReject = sender.lastSentMethod as! AMQBasicReject
        XCTAssertEqual(expected, actual)
    }

}
