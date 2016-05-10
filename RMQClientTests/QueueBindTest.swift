import XCTest

class QueueBindTest: XCTestCase {

    func testQueueBindSendsAQueueBind() {
        let sender = SenderSpy()
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(321, sender: sender, validator: validator, commandQueue: q)
        ch.activateWithDelegate(nil)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedFrameset = RMQFrameset(
            channelNumber: 321,
            method: MethodFixtures.queueBind("my-q", exchangeName: "my-exchange", routingKey: "hi")
        )

        try! q.step()

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueBindWaitsOnBindOk() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 321, method: MethodFixtures.queueBindOk()))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testQueueBindSendsvalidatorrorsToDelegate() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 321, method: MethodFixtures.basicGetOk("wrong method")))
        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError?.code)
    }

    func testQueueUnbindSendsUnbind() {
        let sender = SenderSpy()
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let ch = RMQAllocatedChannel(321, sender: sender, validator: validator, commandQueue: q)
        ch.activateWithDelegate(nil)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedFrameset = RMQFrameset(
            channelNumber: 321,
            method: MethodFixtures.queueUnbind("my-q", exchangeName: "my-exchange", routingKey: "hi")
        )

        try! q.step()

        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last)
    }

    func testQueueUnbindWaitsOnUnbindOk() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 321, method: MethodFixtures.queueUnbindOk()))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testQueueUnbindSendsvalidatorrorsToDelegate() {
        let validator = RMQFramesetValidator()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(321, sender: SenderSpy(), validator: validator, commandQueue: q)
        ch.activateWithDelegate(delegate)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        try! q.step()
        ch.handleFrameset(RMQFrameset(channelNumber: 321, method: MethodFixtures.queueDeclareOk("wrong method")))
        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError?.code)
    }

}
