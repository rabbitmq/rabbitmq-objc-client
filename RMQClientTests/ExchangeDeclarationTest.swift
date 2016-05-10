import XCTest

class ExchangeDeclarationTest: XCTestCase {

    func testExchangeDeclareSendsAnExchangeDeclare() {
        let sender = SenderSpy()
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: waiter, commandQueue: q)

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
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), waiter: waiter, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()
        try! q.step()

        XCTAssertEqual("RMQExchangeDeclareOk", waiter.lastWaitedOnClass?.description())
    }

    func testExchangeDeclareSendsWaitErrorsToDelegate() {
        let waiter = FramesetWaiterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), waiter: waiter, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()
        waiter.err("badness")
        try! q.step()

        XCTAssertEqual("badness", delegate.lastChannelError?.localizedDescription)
    }

    func testFanoutDeclaresAFanout() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

        ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testFanoutReturnsExistingFanoutWithSameNameEvenIfDifferentOptionsOrTypes() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

        let ex1 = ch.topic("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.fanout("my-exchange")

        XCTAssertEqual(ex1, ex2)
    }

    func testDirectDeclaresADirectExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

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
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

        let ex1 = ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.direct("my-exchange")

        XCTAssertEqual(ex1, ex2)
    }

    func testTopicDeclaresATopicExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

        ch.topic("logs", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("logs", type: "topic", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testHeadersDeclaresAHeadersExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, waiter: FramesetWaiterSpy(), commandQueue: q)

        ch.headers("myheadersex", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("myheadersex", type: "headers", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }
}
