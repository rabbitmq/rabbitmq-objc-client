import XCTest

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue())
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

}
