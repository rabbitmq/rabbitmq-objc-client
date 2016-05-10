import XCTest

class RMQSuspendResumeDispatcherTest: XCTestCase {

    func testActivatingResumesQueue() {
        let q = FakeSerialQueue()
        q.suspend()
        let dispatcher = RMQSuspendResumeDispatcher(sender: SenderSpy(), validator: RMQFramesetValidator(), commandQueue: q)
        dispatcher.activateWithChannel(nil, delegate: nil)
        XCTAssertFalse(q.suspended)
    }

    func testSyncMethodsSentToSender() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: nil)

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGet())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testSyncMethodFailureSendsErrorToDelegate() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())

        try! q.step()

        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))

        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError!.code)
    }

    func testBlockingSyncMethodsSentToSender() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let delegate = ConnectionDelegateSpy()
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendSyncMethodBlocking(MethodFixtures.basicGet())

        XCTAssertEqual(2, q.blockingItems.count)

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGet())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)

        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGetOk("foo")))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testBlockingErrorsSentToDelegate() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        let delegate = ConnectionDelegateSpy()
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendSyncMethodBlocking(MethodFixtures.basicGet())

        try! q.step()
        try! q.step()

        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError!.code)
    }
    
    func testAsyncMethodSendsFrameset() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendAsyncMethod(MethodFixtures.channelOpen())

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpen())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testAsyncFramesetSendsFrameset() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, validator: RMQFramesetValidator(), commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        let frameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpen())
        dispatcher.sendAsyncFrameset(frameset)

        try! q.step()

        XCTAssertEqual(frameset, sender.sentFramesets.last!)
    }

}
