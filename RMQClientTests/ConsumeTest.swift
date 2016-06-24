import XCTest

class ConsumeTest: XCTestCase {

    func testBasicConsumeSendsBasicConsumeMethod() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)

        ch.activateWithDelegate(delegate)

        nameGenerator.nextName = "a tag"
        ch.basicConsume("foo", options: [.Exclusive]) { _ in }

        XCTAssertEqual(MethodFixtures.basicConsume("foo", consumerTag: "a tag", options: [.Exclusive]),
                       dispatcher.lastSyncMethod as? RMQBasicConsume)
    }

    func testBasicConsumeReturnsConsumerInstanceWithGeneratedTag() {
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, nameGenerator: nameGenerator)
        nameGenerator.nextName = "stubbed tag"

        let consumer = ch.basicConsume("foo", options: [.Exclusive]) { _ in }

        XCTAssertEqual("stubbed tag", consumer.tag)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkMethod = RMQBasicConsumeOk(consumerTag: RMQShortstr("tag"))
        let consumeOkFrameset = RMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let incomingDeliver = deliverFrameset(
            consumerTag: "tag",
            deliveryTag: 456,
            routingKey: "foo",
            content: "Consumed!",
            channelNumber: 432,
            exchange: "my-exchange",
            options: [.Redelivered]
        )
        let expectedMessage = RMQMessage(content: "Consumed!",
                                         consumerTag: "tag",
                                         deliveryTag: 456,
                                         redelivered: true,
                                         exchangeName: "my-exchange",
                                         routingKey: "foo",
                                         properties: [])

        ch.activateWithDelegate(nil)

        nameGenerator.nextName = "tag"
        var consumedMessage: RMQMessage?
        ch.basicConsume("somequeue", options: []) { message in
            consumedMessage = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        ch.handleFrameset(incomingDeliver)
        XCTAssertNil(consumedMessage)
        try! dispatcher.step()

        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicCancelSendsBasicCancelMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.basicCancel("my tag")

        XCTAssertEqual(MethodFixtures.basicCancel("my tag"), dispatcher.lastSyncMethod as? RMQBasicCancel)
    }

    func testBasicCancelRemovesConsumer() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.basicCancel(consumer.tag)

        ch.handleFrameset(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! dispatcher.step()

        XCTAssertFalse(consumerCalled)
    }

    func testServerCancelRemovesExtantConsumer() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicCancel(consumer.tag)))
        try! dispatcher.step()

        ch.handleFrameset(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! dispatcher.step()

        XCTAssertFalse(consumerCalled)
    }

    // MARK: Helpers

    func deliverFrameset(consumerTag consumerTag: String, deliveryTag: UInt64 = 123, routingKey: String, content: String, channelNumber: Int, exchange: String = "", options: RMQBasicDeliverOptions = []) -> RMQFrameset {
        let deliverMethod = MethodFixtures.basicDeliver(
            consumerTag: consumerTag,
            deliveryTag: deliveryTag,
            routingKey: routingKey,
            exchange: exchange,
            options: options
        )
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: content.dataUsingEncoding(NSUTF8StringEncoding)!)
        return RMQFrameset(channelNumber: channelNumber, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
    }

}
