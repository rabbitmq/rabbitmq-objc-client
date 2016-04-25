import XCTest

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: FramesetWaiterSpy(), queue: q)

        ch.queue("bagpuss")

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclare("bagpuss", options: []))

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueWaitsForDeclareOk() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let waiter = FramesetWaiterSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter, queue: q)

        ch.queue("bagpuss")

        try! q.step()

        XCTAssertEqual("RMQQueueDeclareOk", waiter.lastWaitedOnClass?.description())
    }

    func testQueueSendsWaitErrorsToDelegate() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let waiter = FramesetWaiterSpy()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(1, sender: sender, waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.queue("bagpuss")

        waiter.err("bad news")
        try! q.step()

        XCTAssertEqual("bad news", delegate.lastChannelError?.localizedDescription)
    }

}
