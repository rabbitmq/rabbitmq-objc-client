import XCTest

class ChannelRecoveryTest: XCTestCase {

    func testReopensChannel() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.recover()

        XCTAssertEqual(MethodFixtures.channelOpen(), dispatcher.syncMethodsSent[0] as? RMQChannelOpen)
    }

    func testReinstatesLastSentPrefetchSettings() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.basicQos(2, global: false) // 2 per consumer
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        ch.basicQos(3, global: true)  // 3 per channel
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssertEqual(MethodFixtures.basicQos(2, options: []), dispatcher.syncMethodsSent[1] as? RMQBasicQos)
        XCTAssertEqual(MethodFixtures.basicQos(3, options: [.Global]), dispatcher.syncMethodsSent[2] as? RMQBasicQos)
    }

    func testDoesNotReinstatePrefetchSettingsIfNoneSet() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.recover()

        XCTAssertFalse(dispatcher.syncMethodsSent.contains { $0.isKindOfClass(RMQBasicQos.self) })
    }

    func testRedeclaresQueuesThatHadNotBeenDeleted() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.queue("a", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("a")))

        ch.queue("b")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("b")))

        ch.queue("c")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("c")))

        ch.queueDelete("b", options: [.IfUnused])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeleteOk(123)))

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(dispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("a", options: [.AutoDelete]) })
        XCTAssert(dispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("c", options: []) })
        XCTAssertFalse(dispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("b", options: []) })
    }

    func testRedeclaredQueuesAreStillMemoized() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.queue("a", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("a")))

        ch.recover()

        dispatcher.syncMethodsSent = []
        ch.queue("a", options: [.AutoDelete])
        XCTAssertEqual(0, dispatcher.syncMethodsSent.count)
    }

    func testRedeclaresConsumersNotPreviouslyCancelledByClientOrServer() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: q,
                                     nameGenerator: nameGenerator,
                                     allocator: ChannelSpyAllocator())

        let createContext = (ch, dispatcher, nameGenerator)
        createConsumer("consumer1", createContext)
        createConsumer("consumer2", createContext, [.Exclusive])
        createConsumer("consumer3", createContext)
        createConsumer("consumer4", createContext, [.Exclusive])

        ch.basicCancel("consumer2")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicCancelOk("consumer2")))

        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicCancel("consumer3")))
        try! q.step()

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(dispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer1", options: []) })
        XCTAssert(dispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer4", options: [.Exclusive]) })

        XCTAssertFalse(dispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer2", options: [.Exclusive]) })
        XCTAssertFalse(dispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer3", options: []) })
    }

    func createConsumer(consumerTag: String,
                        _ context: (channel: RMQAllocatedChannel, dispatcher: DispatcherSpy, nameGenerator: StubNameGenerator),
                          _ options: RMQBasicConsumeOptions = []) {
        context.nameGenerator.nextName = consumerTag
        context.channel.basicConsume("q", options: options) { _ in }
        context.dispatcher.lastSyncMethodHandler!(
            RMQFrameset(
                channelNumber: context.channel.channelNumber,
                method: MethodFixtures.basicConsumeOk(consumerTag)
            )
        )
    }

}
