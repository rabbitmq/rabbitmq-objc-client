import XCTest

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.activateWithDelegate(nil)

        ch.queue("bagpuss")

        let expectedMethod = MethodFixtures.queueDeclare("bagpuss", options: [])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

    func testQueueWithEmptyNameGetsClientGeneratedName() {
        let generator = StubNameGenerator()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(),
                                     nameGenerator: generator)
        ch.activateWithDelegate(nil)

        generator.nextName = "mouse-organ"
        let rmqQueue = ch.queue("", options: [])

        let expectedMethod = MethodFixtures.queueDeclare("mouse-organ", options: [])
        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueDeclare)
        XCTAssertEqual("mouse-organ", rmqQueue.name)
    }

    func testQueueWithEmptyNameSendsErrorToDelegateOnNameCollision() {
        let generator = StubNameGenerator()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(),
                                     nameGenerator: generator)
        ch.activateWithDelegate(delegate)

        generator.nextName = "I-will-dupe"

        ch.queue("", options: [])
        ch.queue("")
        XCTAssertEqual(1, dispatcher.syncMethodsSent.count)

        XCTAssertEqual(RMQError.ChannelQueueNameCollision.rawValue, delegate.lastChannelError?.code)
    }

    func testQueueDeleteSendsAQueueDelete() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(123, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.queueDelete("my queue", options: [.IfUnused])
        XCTAssertEqual(MethodFixtures.queueDelete("my queue", options: [.IfUnused]),
                       dispatcher.lastSyncMethod as? RMQQueueDelete)
    }

    func testQueueDeclareAfterDeleteSendsAFreshDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(123, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.queue("my queue")
        ch.queueDelete("my queue", options: [])
        dispatcher.lastSyncMethod = nil
        ch.queue("my queue")
        XCTAssertEqual(MethodFixtures.queueDeclare("my queue", options: []), dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

}
