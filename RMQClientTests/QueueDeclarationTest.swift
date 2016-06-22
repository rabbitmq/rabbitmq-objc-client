import XCTest

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activateWithDelegate(nil)

        ch.queue("bagpuss")

        let expectedMethod = MethodFixtures.queueDeclare("bagpuss", options: [])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

    func testQueueWithEmptyNameGetsClientGeneratedName() {
        let generator = StubNameGenerator()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: generator)

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
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: generator)

        ch.activateWithDelegate(delegate)

        generator.nextName = "I-will-dupe"

        ch.queue("", options: [])
        ch.queue("")
        XCTAssertEqual(1, dispatcher.syncMethodsSent.count)

        XCTAssertEqual(RMQError.ChannelQueueNameCollision.rawValue, delegate.lastChannelError?.code)
    }

    func testQueueWithArguments() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.queue("priority-queue", options: [], arguments: ["x-max-priority": RMQShort(10)])

        XCTAssertEqual(MethodFixtures.queueDeclare("priority-queue", options: [], arguments: ["x-max-priority": RMQShort(10)]),
                       dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

    func testQueueDeleteSendsAQueueDelete() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.queueDelete("my queue", options: [.IfUnused])
        XCTAssertEqual(MethodFixtures.queueDelete("my queue", options: [.IfUnused]),
                       dispatcher.lastSyncMethod as? RMQQueueDelete)
    }

    func testQueueDeclareAfterDeleteSendsAFreshDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.queue("my queue")
        ch.queueDelete("my queue", options: [])
        dispatcher.lastSyncMethod = nil
        ch.queue("my queue")
        XCTAssertEqual(MethodFixtures.queueDeclare("my queue", options: []), dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

}
