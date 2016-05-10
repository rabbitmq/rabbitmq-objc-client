import XCTest

class RMQAllocatedChannelTest: XCTestCase {
    var waiter: FramesetWaiterSpy?

    override func setUp() {
        waiter = FramesetWaiterSpy()
    }

    func testObeysContract() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: RMQGCDSerialQueue(name: "channel command queue"))
        let contract = RMQChannelContract(channel)

        contract.check()
    }

    func testResumesCommandQueueOnActivation() {
        let q = FakeSerialQueue()
        q.suspend()

        let ch = RMQAllocatedChannel(1, sender: SenderSpy(), waiter: waiter!, commandQueue: q)

        ch.activateWithDelegate(nil)

        XCTAssertFalse(q.suspended)
    }

    func testIncomingSyncFramesetsAreSentToWaiter() {
        let sender = SenderSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: FakeSerialQueue())
        let frameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        ch.activateWithDelegate(nil)

        ch.handleFrameset(frameset)

        XCTAssertEqual(frameset, waiter?.lastFulfilledFrameset)
    }

    func testOpeningSendsAChannelOpen() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let openOk = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)

        ch.activateWithDelegate(delegate)

        ch.open()
        XCTAssert(sender.sentFramesets.isEmpty, "Something was sent prematurely!")

        ch.handleFrameset(openOk)
        try! q.step()

        XCTAssertEqual(
            RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()),
            sender.sentFramesets.last!
        )

        XCTAssertNil(delegate.lastChannelOpenError)
    }

    func testOpeningFailsIfWaitFails() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.open()
        try! q.step()
        waiter?.err("foo")
        try! q.step()

        XCTAssertEqual("foo", delegate.lastChannelError!.localizedDescription)
    }

    func testBlockingCloseSendsCloseAndBlocksUntilCloseOkReceived() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(nil)
        ch.open()

        ch.blockingClose()

        XCTAssertEqual(0, sender.sentFramesets.count)
        XCTAssertEqual(2, q.blockingItems.count)

        try! q.step()
        XCTAssertEqual(
            RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()),
            sender.sentFramesets.last
        )
        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk()))
        try! q.step()

        try! q.step()
        XCTAssertEqual(
            RMQFrameset(channelNumber: 1, method: MethodFixtures.channelClose()),
            sender.sentFramesets.last
        )

        XCTAssertEqual(RMQChannelOpenOk.description(), waiter!.lastWaitedOnClass!.description())
        try! q.step()

        XCTAssertEqual(RMQChannelCloseOk.description(), waiter!.lastWaitedOnClass!.description())
    }

    func testBlockingCloseSendsMessageToDelegateIfWaitFails() {
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.open()
        try! q.step()
        try! q.step()

        ch.blockingClose()

        try! q.step()
        waiter!.err("waiting failed")
        try! q.step()

        XCTAssertEqual("waiting failed", delegate.lastChannelError?.localizedDescription)
    }

    func testBlockingWaitOnBlocksUntilSpecifiedMethodReceived() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)

        ch.blockingWaitOn(RMQConnectionCloseOk.self)
        XCTAssertNil(waiter?.lastWaitedOnClass)

        XCTAssertEqual(2, q.blockingItems.count)

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 0, method: MethodFixtures.connectionCloseOk()))
        try! q.step()

        XCTAssertEqual("RMQConnectionCloseOk", waiter?.lastWaitedOnClass!.description())
    }

    func testBlockingWaitOnSendsMessageToDelegateIfWaitFails() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.blockingWaitOn(RMQConnectionCloseOk.self)

        try! q.step()
        waiter!.err("Timed out, buddy.")
        try! q.step()

        XCTAssertEqual("Timed out, buddy.", delegate.lastChannelError?.localizedDescription)
    }

    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)
        let expectedMethod = RMQBasicConsume(
            reserved1: RMQShort(0),
            queue: RMQShortstr("a_queue_name"),
            consumerTag: RMQShortstr(""),
            options: [.NoAck],
            arguments: RMQTable([:])
        )

        channel.basicConsume("a_queue_name", options: [.NoAck]) { (_, _) in }
        XCTAssertNil(sender.lastSentMethod)

        waiter!.fulfill(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("heres-ur-tag-bro")))
        try! q.step()
        let receivedMethod = sender.lastSentMethod! as! RMQBasicConsume
        XCTAssertEqual(expectedMethod, receivedMethod)
    }

    func testBasicConsumeSendsErrorToDelegateOnWaitError() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()

        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(delegate)

        channel.basicConsume("a_queue_name", options: []) { (_, _) in
            XCTFail("Should not be called")
        }

        try! q.step()
        waiter!.err("fooey")
        try! q.step()

        XCTAssertEqual("fooey", delegate.lastChannelError?.localizedDescription)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, commandQueue: q)
        let consumeOkMethod = RMQBasicConsumeOk(consumerTag: RMQShortstr("servergeneratedtag"))
        let consumeOkFrameset = RMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: "servergeneratedtag", deliveryTag: 123, routingKey: "foo")
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset = RMQFrameset(channelNumber: 432, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
        let expectedDeliveryInfo = RMQDeliveryInfo(routingKey: "foo")
        let expectedMessage = RMQMessage(consumerTag: "servergeneratedtag", deliveryTag: 123, content: "Consumed!")

        channel.activateWithDelegate(nil)

        var receivedDeliveryInfo: RMQDeliveryInfo?
        var consumedMessage: RMQMessage?

        waiter?.fulfill(consumeOkFrameset)
        channel.basicConsume("somequeue", options: []) { (di, message) in
            receivedDeliveryInfo = di
            consumedMessage = message
        }
        try! q.step()
        try! q.step()

        XCTAssertNil(receivedDeliveryInfo)
        XCTAssertNil(consumedMessage)
        channel.handleFrameset(deliverFrameset)
        try! q.step()

        XCTAssertEqual(expectedDeliveryInfo, receivedDeliveryInfo)
        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicGetSendsBasicGet() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(nil)

        ch.basicGet("my-q", options: [.NoAck]) { _ in }

        XCTAssertEqual(0, sender.sentFramesets.count)

        try! q.step()

        let expected = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicGet("my-q", options: [.NoAck]))
        let actual = sender.sentFramesets.last!
        XCTAssertEqual(expected, actual)
    }

    func testBasicGetCallsCompletionHandlerWithMessageAndDeliveryInfo() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let getOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicGetOk("my-q", deliveryTag: 1),
            contentHeader: RMQContentHeader(classID: 60, bodySize: 123, properties: []),
            contentBodies: [RMQContentBody(data: "hello".dataUsingEncoding(NSUTF8StringEncoding)!)]
        )
        let expectedDeliveryInfo = RMQDeliveryInfo(routingKey: "my-q")
        let expectedMessage = RMQMessage(consumerTag: "", deliveryTag: 1, content: "hello")
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter!, commandQueue: q)
        ch.activateWithDelegate(nil)

        var receivedMessage: RMQMessage?
        var receivedDeliveryInfo: RMQDeliveryInfo?
        ch.basicGet("my-q", options: [.NoAck]) { (di, m) in
            receivedDeliveryInfo = di
            receivedMessage = m
        }

        try! q.step()
        ch.handleFrameset(getOkFrameset)
        try! q.step()

        XCTAssertEqual(expectedDeliveryInfo, receivedDeliveryInfo)
        XCTAssertEqual(expectedMessage, receivedMessage)
    }

    func testBasicGetSendsErrorToDelegateOnWaitError() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()

        let channel = RMQAllocatedChannel(432, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(delegate)

        q.suspend()
        channel.basicGet("naughty-q", options: []) { _ in
            XCTFail("Should not be called")
        }

        try! q.step()
        waiter!.err("oh no!")
        try! q.step()

        XCTAssertEqual("oh no!", delegate.lastChannelError?.localizedDescription)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, commandQueue: q)
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
        let expectedMessage1 = RMQMessage(consumerTag: "servertag1", deliveryTag: 1, content: "A message for consumer 1")
        let expectedMessage2 = RMQMessage(consumerTag: "servertag2", deliveryTag: 1, content: "A message for consumer 2")

        ch.activateWithDelegate(nil)

        var consumedMessage1: RMQMessage?
        ch.basicConsume("sameq", options: []) { (_, message) in
            consumedMessage1 = message
        }
        try! q.step()
        ch.handleFrameset(consumeOkFrameset1)
        try! q.step()

        var consumedMessage2: RMQMessage?
        ch.basicConsume("sameq", options: []) { (_, message) in
            consumedMessage2 = message
        }
        try! q.step()
        ch.handleFrameset(consumeOkFrameset2)
        try! q.step()

        ch.handleFrameset(deliverFrameset1)
        ch.handleFrameset(deliverFrameset2)
        try! q.step()

        XCTAssertEqual(expectedMessage1, consumedMessage1)

        try! q.step()
        XCTAssertEqual(expectedMessage2, consumedMessage2)
    }

    func testBasicPublishSendsFramesetToSenderOnOwnQueue() {
        let sender = SenderSpy(frameMax: 4 + RMQEmptyFrameSize)
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        let message = "my great message yo"
        let notPersistent = RMQBasicDeliveryMode(1)

        let expectedMethod = RMQBasicPublish(
            reserved1: RMQShort(0),
            exchange: RMQShortstr(""),
            routingKey: RMQShortstr("my.q"),
            options: RMQBasicPublishOptions.NoOptions
        )
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: message.dataUsingEncoding(NSUTF8StringEncoding)!.length,
            properties: [notPersistent, RMQBasicContentType("application/octet-stream"), RMQBasicPriority(0)]
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

        ch.basicPublish(message, routingKey: "my.q", exchange: "", persistent: false)

        XCTAssertEqual(0, sender.sentFramesets.count)

        try! q.step()

        XCTAssertEqual(5, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let sender = SenderSpy(frameMax: 4 + RMQEmptyFrameSize)
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
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

        channel.basicPublish(messageContent, routingKey: "my.q", exchange: "", persistent: true)

        try! q.step()

        XCTAssertEqual(2, sender.sentFramesets.last!.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.sentFramesets.last!.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testBasicQosSendsBasicQosGlobal() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)
        q.suspend()

        channel.basicQos(32, global: true)

        XCTAssertNil(sender.lastSentMethod)

        try! q.step()

        let expectedMethod = MethodFixtures.basicQos(32, options: [.Global])
        let actualMethod = sender.lastSentMethod as! RMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosSendsBasicQosNonGlobal() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)

        channel.basicQos(32, global: false)

        XCTAssertNil(sender.lastSentMethod)

        try! q.step()

        let expectedMethod = MethodFixtures.basicQos(32, options: [])
        let actualMethod = sender.lastSentMethod as! RMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosWaitsOnBasicQosOk() {
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)

        channel.basicQos(64, global: false)

        try! q.step()

        XCTAssert(q.suspended)

        try! q.step()

        XCTAssertEqual(RMQBasicQosOk.self.description(), waiter!.lastWaitedOnClass!.description())
    }

    func testBasicQosSendsErrorToDelegateOnWaitError() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let channel = RMQAllocatedChannel(999, sender: SenderSpy(), waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(delegate)

        channel.basicQos(64, global: false)

        waiter?.err("bad stuff")
        try! q.step()
        try! q.step()

        XCTAssertEqual("bad stuff", delegate.lastChannelError?.localizedDescription)
    }

    func testAckSendsABasicAck() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()

        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)

        channel.ack(123, options: [.Multiple])

        XCTAssertEqual(0, sender.sentFramesets.count)

        try! q.step()

        let expected = RMQBasicAck(deliveryTag: RMQLonglong(123), options: [.Multiple])
        let actual: RMQBasicAck = sender.lastSentMethod as! RMQBasicAck
        XCTAssertEqual(expected, actual)
    }

    func testRejectSendsABasicReject() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)

        channel.reject(123, options: [.Requeue])

        XCTAssertEqual(0, sender.sentFramesets.count)

        try! q.step()

        let expected = RMQBasicReject(deliveryTag: RMQLonglong(123), options: [.Requeue])
        let actual: RMQBasicReject = sender.lastSentMethod as! RMQBasicReject
        XCTAssertEqual(expected, actual)
    }

    func testNackSendsABasicNack() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let channel = RMQAllocatedChannel(999, sender: sender, waiter: waiter!, commandQueue: q)
        channel.activateWithDelegate(nil)

        channel.nack(123, options: [.Multiple, .Requeue])

        XCTAssertEqual(0, sender.sentFramesets.count)

        try! q.step()

        let expected = RMQBasicNack(deliveryTag: RMQLonglong(123), options: [.Multiple, .Requeue])
        let actual: RMQBasicNack = sender.lastSentMethod as! RMQBasicNack
        XCTAssertEqual(expected, actual)
    }
    
}
