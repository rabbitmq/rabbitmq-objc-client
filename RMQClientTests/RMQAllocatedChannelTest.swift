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
        let frameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        ch.activateWithDelegate(nil)
        q.suspend()

        ch.handleFrameset(frameset)

        XCTAssertEqual(frameset, waiter?.lastFulfilledFrameset)
    }

    func testOpeningSendsAChannelOpen() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let openOk = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)

        ch.activateWithDelegate(delegate)
        q.suspend()

        ch.open()
        XCTAssert(sender.sentFramesets.isEmpty, "Something was sent prematurely!")

        ch.handleFrameset(openOk)
        q.finish()

        XCTAssertEqual(
            RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()),
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

    func testBlockingCloseSendsCloseAndBlocksUntilCloseOkReceived() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        ch.activateWithDelegate(nil)
        ch.open()
        
        waiter!.fulfill(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelCloseOk()))
        ch.blockingClose()

        XCTAssertEqual(
            [
                RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()),
                RMQFrameset(channelNumber: 1, method: MethodFixtures.channelClose())
            ],
            sender.sentFramesets
        )
        XCTAssertEqual(RMQChannelCloseOk.description(), waiter!.lastWaitedOnClass!.description())

        q.suspend()
    }

    func testBlockingCloseSendsMessageToDelegateIfWaitFails() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        ch.activateWithDelegate(delegate)
        ch.open()

        waiter!.err("waiting failed")
        ch.blockingClose()
        XCTAssertEqual("waiting failed", delegate.lastChannelError?.localizedDescription)

        q.suspend()
    }

    func testQueueSendsAQueueDeclareWithNoWait() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)

        ch.queue("bagpuss")

        XCTAssertEqual(0, sender.sentFramesets.count)
        q.finish()

        let expectedQueueDeclare = RMQQueueDeclare(
            reserved1: RMQShort(0),
            queue: RMQShortstr("bagpuss"),
            options: [.NoWait],
            arguments: RMQTable([:])
        )
        let actualFrame = sender.sentFramesets.last!
        let actualMethod = actualFrame.method as! RMQQueueDeclare
        XCTAssertEqual(expectedQueueDeclare, actualMethod)
    }

    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        let expectedMethod = RMQBasicConsume(
            reserved1: RMQShort(0),
            queue: RMQShortstr("a_queue_name"),
            consumerTag: RMQShortstr(""),
            options: [.NoAck],
            arguments: RMQTable([:])
        )

        q.suspend()

        channel.basicConsume("a_queue_name", options: [.NoAck]) { message in }
        XCTAssertNil(sender.lastSentMethod)

        waiter!.fulfill(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("heres-ur-tag-bro")))
        q.finish()
        let receivedMethod = sender.lastSentMethod! as! RMQBasicConsume
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
        let consumeOkMethod = RMQBasicConsumeOk(consumerTag: RMQShortstr("servergeneratedtag"))
        let consumeOkFrameset = RMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: "servergeneratedtag", deliveryTag: 123)
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset = RMQFrameset(channelNumber: 432, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
        let expectedMessage = RMQContentMessage(consumerTag: "servergeneratedtag", deliveryTag: 123, content: "Consumed!")

        channel.activateWithDelegate(nil)

        var consumedMessage: RMQContentMessage?

        waiter?.fulfill(consumeOkFrameset)
        channel.basicConsume("somequeue", options: []) { message in
            consumedMessage = message as? RMQContentMessage
        }
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

        let expected = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicGet("my-q", options: [.NoAck]))
        let actual = sender.sentFramesets.last!
        XCTAssertEqual(expected, actual)
    }

    func testBasicGetCallsCompletionHandlerWithMessage() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let getOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicGetOk("my-q", deliveryTag: 1),
            contentHeader: RMQContentHeader(classID: 60, bodySize: 123, properties: []),
            contentBodies: [RMQContentBody(data: "hello".dataUsingEncoding(NSUTF8StringEncoding)!)]
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
        let consumeOkFrameset1 = RMQFrameset(channelNumber: 999, method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag1")))
        let consumeOkFrameset2 = RMQFrameset(channelNumber: 999, method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag2")))
        let deliverMethod1 = MethodFixtures.basicDeliver(consumerTag: "servertag1", deliveryTag: 1)
        let deliverHeader1 = RMQContentHeader(classID: deliverMethod1.classID(), bodySize: 123, properties: [])
        let deliverBody1 = RMQContentBody(data: "A message for consumer 1".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset1 = RMQFrameset(channelNumber: 999, method: deliverMethod1, contentHeader: deliverHeader1, contentBodies: [deliverBody1])
        let deliverMethod2 = MethodFixtures.basicDeliver(consumerTag: "servertag2", deliveryTag: 1)
        let deliverHeader2 = RMQContentHeader(classID: deliverMethod2.classID(), bodySize: 123, properties: [])
        let deliverBody2 = RMQContentBody(data: "A message for consumer 2".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset2 = RMQFrameset(channelNumber: 999, method: deliverMethod2, contentHeader: deliverHeader2, contentBodies: [deliverBody2])
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
        let sender = SenderSpy(frameMax: 4 + RMQEmptyFrameSize)
        let q = QueueHelper()
        let ch = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let message = "my great message yo"
        let persistent = RMQBasicDeliveryMode(2)

        let expectedMethod = RMQBasicPublish(
            reserved1: RMQShort(0),
            exchange: RMQShortstr(""),
            routingKey: RMQShortstr("my.q"),
            options: RMQBasicPublishOptions.NoOptions
        )
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: message.dataUsingEncoding(NSUTF8StringEncoding)!.length,
            properties: [persistent, RMQBasicContentType("application/octet-stream"), RMQBasicPriority(0)]
        )
        let expectedBodies = [
            RMQContentBody(data: "my g".dataUsingEncoding(NSUTF8StringEncoding)!),
            RMQContentBody(data: "reat".dataUsingEncoding(NSUTF8StringEncoding)!),
            RMQContentBody(data: " mes".dataUsingEncoding(NSUTF8StringEncoding)!),
            RMQContentBody(data: "sage".dataUsingEncoding(NSUTF8StringEncoding)!),
            RMQContentBody(data: " yo".dataUsingEncoding(NSUTF8StringEncoding)!),
            ]
        let expectedFrameset = RMQFrameset(
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
        let sender = SenderSpy(frameMax: 4 + RMQEmptyFrameSize)
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        let messageContent = "12345678"
        let expectedMethod = RMQBasicPublish(
            reserved1: RMQShort(0),
            exchange: RMQShortstr(""),
            routingKey: RMQShortstr("my.q"),
            options: RMQBasicPublishOptions.NoOptions
        )
        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!
        let persistent = RMQBasicDeliveryMode(2)
        let contentTypeOctetStream = RMQBasicContentType("application/octet-stream")
        let lowPriority = RMQBasicPriority(0)
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )
        let expectedBodies = [
            RMQContentBody(data: "1234".dataUsingEncoding(NSUTF8StringEncoding)!),
            RMQContentBody(data: "5678".dataUsingEncoding(NSUTF8StringEncoding)!),
            ]
        let expectedFrameset = RMQFrameset(
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
        let actualMethod = sender.lastSentMethod as! RMQBasicQos
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
        let actualMethod = sender.lastSentMethod as! RMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosWaitsOnBasicQosOk() {
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicQos(64, global: false)

        q.finish()

        XCTAssertEqual(RMQBasicQosOk.self.description(), waiter?.lastWaitedOnClass!.description())
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

        let expected = RMQBasicAck(deliveryTag: RMQLonglong(123), options: [.Multiple])
        let actual: RMQBasicAck = sender.lastSentMethod as! RMQBasicAck
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

        let expected = RMQBasicReject(deliveryTag: RMQLonglong(123), options: [.Requeue])
        let actual: RMQBasicReject = sender.lastSentMethod as! RMQBasicReject
        XCTAssertEqual(expected, actual)
    }

    func testNackSendsABasicNack() {
        let sender = SenderSpy()
        let q = QueueHelper()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, queue: q.dispatchQueue)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.nack(123, options: [.Multiple, .Requeue])

        XCTAssertEqual(0, sender.sentFramesets.count)

        q.finish()

        let expected = RMQBasicNack(deliveryTag: RMQLonglong(123), options: [.Multiple, .Requeue])
        let actual: RMQBasicNack = sender.lastSentMethod as! RMQBasicNack
        XCTAssertEqual(expected, actual)
    }
    
}
