import XCTest

class RMQAllocatedChannelTest: XCTestCase {

    func testObeysContract() {
        let sender = SenderSpy()
        let q = RMQGCDSerialQueue(name: "channel command queue")
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        let contract = RMQChannelContract(ch)

        contract.check()
    }

    func testActivatingActivatesDispatcher() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()

        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        XCTAssertEqual(ch, dispatcher.activatedWithChannel as? RMQAllocatedChannel)
        XCTAssertEqual(delegate, dispatcher.activatedWithDelegate as? ConnectionDelegateSpy)
    }

    func testIncomingSyncFramesetsAreSentToDispatcher() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()

        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        let frameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicGetOk(routingKey: "route-me"))
        ch.handleFrameset(frameset)

        XCTAssertEqual(frameset, dispatcher.lastFramesetHandled)
    }

    func testOpeningSendsAChannelOpen() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.open()

        XCTAssertEqual(MethodFixtures.channelOpen(), dispatcher.lastSyncMethod as? RMQChannelOpen)
    }

    func testCloseSendsClose() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.close()

        XCTAssertEqual(MethodFixtures.channelClose(), dispatcher.lastSyncMethod as? RMQChannelClose)
    }

    func testCloseReleasesItsChannelNumberWhenCloseOkReceived() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let allocator = ChannelSpyAllocator()

        allocator.allocate() // 0
        allocator.allocate() // 1

        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: allocator)

        ch.close()

        XCTAssertEqual(2, allocator.channels.count)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelCloseOk()))
        XCTAssertEqual([allocator.channels[0]], allocator.channels)
    }

    func testBlockingCloseSendsCloseAndBlocksUntilCloseOkReceived() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        ch.activateWithDelegate(delegate)

        ch.open()
        ch.blockingClose()

        XCTAssertEqual(MethodFixtures.channelClose(), dispatcher.lastBlockingSyncMethod as? RMQChannelClose)
    }

    func testBlockingCloseReleasesItsChannelNumberFromAllocatorWhenDone() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let allocator = ChannelSpyAllocator()

        allocator.allocate() // 0
        allocator.allocate() // 1

        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: allocator)

        XCTAssertEqual(2, allocator.channels.count)
        ch.blockingClose()
        XCTAssertEqual([allocator.channels[0]], allocator.channels)
    }

    func testBlockingWaitOnDelegatesToDispatcher() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        ch.activateWithDelegate(delegate)

        ch.blockingWaitOn(RMQChannelCloseOk.self)

        XCTAssertEqual("RMQChannelCloseOk", dispatcher.lastBlockingWaitOn)
    }

    func testBasicGetSendsBasicGetMethod() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.basicGet("queuey", options: [.NoAck]) { _ in }

        XCTAssertEqual(MethodFixtures.basicGet("queuey", options: [.NoAck]),
                       dispatcher.lastSyncMethod as? RMQBasicGet)
    }
    
    func testBasicGetCallsCompletionHandlerWithMessageAndDeliveryInfo() {
        let q = FakeSerialQueue()
        let getOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicGetOk(routingKey: "my-q", deliveryTag: 1, exchange: "someex", options: [.Redelivered]),
            contentHeader: RMQContentHeader(classID: 60, bodySize: 123, properties: []),
            contentBodies: [RMQContentBody(data: "hello".dataUsingEncoding(NSUTF8StringEncoding)!)]
        )
        let expectedMessage = RMQMessage(content: "hello", consumerTag: "", deliveryTag: 1, redelivered: true, exchangeName: "someex", routingKey: "my-q")
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        var receivedMessage: RMQMessage?
        ch.basicGet("my-q", options: [.NoAck]) { m in
            receivedMessage = m
        }

        dispatcher.lastSyncMethodHandler!(getOkFrameset)

        XCTAssertEqual(expectedMessage, receivedMessage)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = RMQAllocatedChannel(999, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: nameGenerator, allocator: ChannelSpyAllocator())
        let consumeOkFrameset1 = RMQFrameset(channelNumber: 999, method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag1")))
        let consumeOkFrameset2 = RMQFrameset(channelNumber: 999, method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag2")))
        let deliverMethod1 = MethodFixtures.basicDeliver(consumerTag: "tag1", deliveryTag: 1)
        let deliverHeader1 = RMQContentHeader(classID: deliverMethod1.classID(), bodySize: 123, properties: [])
        let deliverBody1 = RMQContentBody(data: "A message for consumer 1".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset1 = RMQFrameset(channelNumber: 999, method: deliverMethod1, contentHeader: deliverHeader1, contentBodies: [deliverBody1])
        let deliverMethod2 = MethodFixtures.basicDeliver(consumerTag: "tag2", deliveryTag: 1)
        let deliverHeader2 = RMQContentHeader(classID: deliverMethod2.classID(), bodySize: 123, properties: [])
        let deliverBody2 = RMQContentBody(data: "A message for consumer 2".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliverFrameset2 = RMQFrameset(channelNumber: 999, method: deliverMethod2, contentHeader: deliverHeader2, contentBodies: [deliverBody2])
        let expectedMessage1 = RMQMessage(content: "A message for consumer 1", consumerTag: "tag1", deliveryTag: 1, redelivered: false, exchangeName: "", routingKey: "")
        let expectedMessage2 = RMQMessage(content: "A message for consumer 2", consumerTag: "tag2", deliveryTag: 1, redelivered: false, exchangeName: "", routingKey: "")

        ch.activateWithDelegate(nil)

        nameGenerator.nextName = "tag1"
        var consumedMessage1: RMQMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage1 = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset1)

        nameGenerator.nextName = "tag2"
        var consumedMessage2: RMQMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage2 = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset2)

        ch.handleFrameset(deliverFrameset1)
        ch.handleFrameset(deliverFrameset2)
        try! q.step()

        XCTAssertEqual(expectedMessage1, consumedMessage1)

        try! q.step()
        XCTAssertEqual(expectedMessage2, consumedMessage2)
    }

    func testBasicPublishSendsAsyncFrameset() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(999, contentBodySize: 4, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        let message = "my great message yo"
        let notPersistent = RMQBasicDeliveryMode(1)
        let customContentType = RMQBasicContentType("my/content-type")
        let priorityZero = RMQBasicPriority(0)

        let expectedMethod = MethodFixtures.basicPublish("my.q", exchange: "", options: [.Immediate, .Mandatory])
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: message.dataUsingEncoding(NSUTF8StringEncoding)!.length,
            properties: [notPersistent, customContentType, priorityZero]
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

        ch.basicPublish(message, routingKey: "my.q", exchange: "",
                        properties: [notPersistent, customContentType, priorityZero],
                        options: [.Immediate, .Mandatory])

        XCTAssertEqual(5, dispatcher.lastAsyncFrameset!.contentBodies.count)
        XCTAssertEqual(expectedBodies, dispatcher.lastAsyncFrameset!.contentBodies)
        XCTAssertEqual(expectedFrameset, dispatcher.lastAsyncFrameset!)
    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(999, contentBodySize: 4, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        let messageContent = "12345678"
        let expectedMethod = MethodFixtures.basicPublish("my.q", exchange: "", options: [])
        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: RMQBasicProperties.defaultProperties()
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

        ch.activateWithDelegate(nil)

        ch.basicPublish(messageContent, routingKey: "my.q", exchange: "", properties: RMQBasicProperties.defaultProperties(), options: [])

        XCTAssertEqual(2, dispatcher.lastAsyncFrameset!.contentBodies.count)
        XCTAssertEqual(expectedBodies, dispatcher.lastAsyncFrameset!.contentBodies)
        XCTAssertEqual(expectedFrameset, dispatcher.lastAsyncFrameset!)
    }

    func testBasicQosSendsBasicQosGlobal() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.basicQos(1, global: true)

        XCTAssertEqual(MethodFixtures.basicQos(1, options: [.Global]),
                       dispatcher.lastSyncMethod as? RMQBasicQos)
    }

    func testAckSendsABasicAck() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.ack(123, options: [.Multiple])

        XCTAssertEqual(MethodFixtures.basicAck(123, options: [.Multiple]),
                       dispatcher.lastAsyncMethod as? RMQBasicAck)
    }
    
    func testRejectSendsABasicReject() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.reject(123, options: [.Requeue])

        XCTAssertEqual(MethodFixtures.basicReject(123, options: [.Requeue]),
                       dispatcher.lastAsyncMethod as? RMQBasicReject)
    }
    
    func testNackSendsABasicNack() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())

        ch.activateWithDelegate(delegate)

        ch.nack(123, options: [.Requeue])

        XCTAssertEqual(MethodFixtures.basicNack(123, options: [.Requeue]),
                       dispatcher.lastAsyncMethod as? RMQBasicNack)
    }
    
}
