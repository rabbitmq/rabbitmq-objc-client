import XCTest

class ExchangeDeclarationTest: XCTestCase {

    func testExchangeDeclareSendsAnExchangeDeclare() {
        let sender = SenderSpy()
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, validator: validator, commandQueue: q)
        ch.activateWithDelegate(nil)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testExchangeDeclareWaitsOnDeclareOk() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.exchangeDeclareOk()))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testExchangeDeclareSendsvalidatorrorsToDelegate() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])
        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.queueDeclareOk("wrong method")))
        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError?.code)
    }

    func testFanoutDeclaresAFanout() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        ch.activateWithDelegate(nil)

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
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)

        let ex1 = ch.topic("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.fanout("my-exchange")

        XCTAssertEqual(ex1, ex2)
    }

    func testDirectDeclaresADirectExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        ch.activateWithDelegate(nil)

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
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)

        let ex1 = ch.fanout("my-exchange", options: [.Durable, .AutoDelete])
        try! q.step()
        let ex2 = ch.direct("my-exchange")

        XCTAssertEqual(ex1, ex2)
    }

    func testTopicDeclaresATopicExchange() {
        let sender = SenderSpy()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        ch.activateWithDelegate(nil)

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
        let ch = RMQAllocatedChannel(123, sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        ch.activateWithDelegate(nil)

        ch.headers("myheadersex", options: [.Durable, .AutoDelete])
        try! q.step()

        let expectedFrameset = RMQFrameset(
            channelNumber: 123,
            method: MethodFixtures.exchangeDeclare("myheadersex", type: "headers", options: [.Durable, .AutoDelete])
        )

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }
}
