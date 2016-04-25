import XCTest

class ExchangeDeclarationTest: XCTestCase {

    func testExchangeDeclareSendsAnExchangeDeclare() {
        let sender = SenderSpy()
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: waiter, queue: q)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testExchangeDeclareWaitsOnDeclareOk() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])

        try! q.step()

        XCTAssertEqual("RMQExchangeDeclareOk", waiter.lastWaitedOnClass?.description())
    }

    func testExchangeDeclareSendsWaitErrorsToDelegate() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), waiter: waiter, queue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        waiter.err("badness")
        try! q.step()

        XCTAssertEqual("badness", delegate.lastChannelError?.localizedDescription)
    }

    func testFanoutDeclaresAFanout() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), queue: q)

        ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testFanoutReturnsExistingFanoutWithSameNameEvenIfDifferentOptions() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), queue: q)

        let ex1 = ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.fanout("my-exchange", options: [.Durable])

        XCTAssertEqual(ex1, ex2)
    }

    func testDirectDeclaresADirectExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), queue: q)

        ch.direct("logs", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("logs", type: "direct", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testDirectReturnsExistingExchangeWithSameNameEvenIfDifferentOptionsOrTypes() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), queue: q)

        let ex1 = ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.direct("my-exchange", options: [.Durable])

        XCTAssertEqual(ex1, ex2)
    }
}
