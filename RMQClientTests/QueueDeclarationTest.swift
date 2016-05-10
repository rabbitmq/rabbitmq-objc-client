import XCTest

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)

        ch.queue("bagpuss")

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclare("bagpuss", options: []))

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueWaitsForDeclareOk() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let validator = RMQFramesetValidator()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queue("bagpuss")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("bagpuss")))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testQueueSendsvalidatorrorsToDelegate() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let validator = RMQFramesetValidator()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queue("bagpuss")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.connectionStartOk()))
        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError?.code)
    }

    func testQueueWithEmptyNameGetsClientGeneratedName() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let validator = RMQFramesetValidator()
        let generator = StubNameGenerator()
        let ch = RMQAllocatedChannel(1, sender: sender, validator: validator, commandQueue: q, nameGenerator: generator)

        generator.nextName = "mouse-organ"
        let rmqQueue = ch.queue("", options: [])

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclare("mouse-organ", options: []))
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
        XCTAssertEqual("mouse-organ", rmqQueue.name)
    }

    func testQueueWithEmptyNameSendsErrorToDelegateOnNameCollision() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let validator = RMQFramesetValidator()
        let generator = StubNameGenerator()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, validator: validator, commandQueue: q, nameGenerator: generator)
        ch.activateWithDelegate(delegate)

        generator.nextName = "I-will-dupe"

        ch.queue("", options: [])
        try! q.step()
        ch.queue("")
        XCTAssertEqual(1, sender.sentFramesets.count)

        XCTAssertEqual("Name collision when generating unique name.", delegate.lastChannelError?.localizedDescription)
    }

}
