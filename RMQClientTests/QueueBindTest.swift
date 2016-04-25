import XCTest

class QueueBindTest: XCTestCase {

    func testQueueBindSendsAQueueBind() {
        let sender = SenderSpy()
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(321, sender: sender, waiter: waiter, queue: q)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedFrameset = RMQFrameset(
            channelNumber: 321,
            method: MethodFixtures.queueBind("my-q", exchangeName: "my-exchange", routingKey: "hi")
        )

        try! q.step()

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueBindWaitsOnBindOk() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "")

        try! q.step()

        XCTAssertEqual("RMQQueueBindOk", waiter.lastWaitedOnClass?.description())
    }

    func testQueueBindSendsWaitErrorsToDelegate() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "")

        waiter.err("foo")
        try! q.step()

        XCTAssertEqual("foo", delegate.lastChannelError?.localizedDescription)
    }

    func testQueueUnbindSendsUnbind() {
        let sender = SenderSpy()
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(321, sender: sender, waiter: waiter, queue: q)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedFrameset = RMQFrameset(
            channelNumber: 321,
            method: MethodFixtures.queueUnbind("my-q", exchangeName: "my-exchange", routingKey: "hi")
        )

        try! q.step()

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueUnbindWaitsOnUnbindOk() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        try! q.step()

        XCTAssertEqual("RMQQueueUnbindOk", waiter.lastWaitedOnClass?.description())
    }

    func testQueueUnbindSendsWaitErrorsToDelegate() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        waiter.err("Oh no")
        try! q.step()

        XCTAssertEqual("Oh no", delegate.lastChannelError?.localizedDescription)
    }

}
