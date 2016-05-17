import XCTest

class ConsumeTest: XCTestCase {

    func testBasicConsumeSendsBasicConsumeMethod() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: nameGenerator)

        ch.activateWithDelegate(delegate)

        nameGenerator.nextName = "a tag"
        ch.basicConsume("foo", options: [.Exclusive]) { (_, _) in }

        XCTAssertEqual(MethodFixtures.basicConsume("foo", consumerTag: "a tag", options: [.Exclusive]),
                       dispatcher.lastSyncMethod as? RMQBasicConsume)
    }

    func testBasicConsumeReturnsConsumerInstanceWithGeneratedTag() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = RMQAllocatedChannel(1, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: nameGenerator)
        nameGenerator.nextName = "stubbed tag"

        let consumer = ch.basicConsume("foo", options: [.Exclusive]) { (_, _) in }

        XCTAssertEqual("stubbed tag", consumer.tag)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = RMQAllocatedChannel(432, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: nameGenerator)
        let consumeOkMethod = RMQBasicConsumeOk(consumerTag: RMQShortstr("tag"))
        let consumeOkFrameset = RMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let incomingDeliver = deliverFrameset("tag", routingKey: "foo", content: "Consumed!", channelNumber: 432)
        let expectedDeliveryInfo = RMQDeliveryInfo(routingKey: "foo")
        let expectedMessage = RMQMessage(consumerTag: "tag", deliveryTag: 123, content: "Consumed!")

        ch.activateWithDelegate(nil)

        nameGenerator.nextName = "tag"
        var receivedDeliveryInfo: RMQDeliveryInfo?
        var consumedMessage: RMQMessage?
        ch.basicConsume("somequeue", options: []) { (di, message) in
            receivedDeliveryInfo = di
            consumedMessage = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        XCTAssertNil(receivedDeliveryInfo)
        XCTAssertNil(consumedMessage)
        ch.handleFrameset(incomingDeliver)
        try! q.step()

        XCTAssertEqual(expectedDeliveryInfo, receivedDeliveryInfo)
        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicCancelSendsBasicCancelMethod() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(432, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator())

        ch.basicCancel("my tag")

        XCTAssertEqual(MethodFixtures.basicCancel("my tag"), dispatcher.lastSyncMethod as? RMQBasicCancel)
    }

    func testBasicCancelRemovesConsumer() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(432, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator())

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.basicCancel(consumer.tag)

        ch.handleFrameset(deliverFrameset(consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! q.step()

        XCTAssertFalse(consumerCalled)
    }

    func testServerCancelRemovesExtantConsumer() {
        let q = FakeSerialQueue()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(432, contentBodySize: 100, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator())

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicCancel(consumer.tag)))
        try! q.step()

        ch.handleFrameset(deliverFrameset(consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! q.step()

        XCTAssertFalse(consumerCalled)
    }

    // MARK: Helpers

    func deliverFrameset(consumerTag: String, routingKey: String, content: String, channelNumber: Int) -> RMQFrameset {
        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: consumerTag, deliveryTag: 123, routingKey: routingKey)
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: content.dataUsingEncoding(NSUTF8StringEncoding)!)
        return RMQFrameset(channelNumber: channelNumber, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
    }

}
