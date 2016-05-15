import XCTest

class RMQSuspendResumeDispatcherTest: XCTestCase {

    func testActivatingResumesQueue() {
        let q = FakeSerialQueue()
        q.suspend()
        let dispatcher = RMQSuspendResumeDispatcher(sender: SenderSpy(), commandQueue: q)
        dispatcher.activateWithChannel(nil, delegate: nil)
        XCTAssertFalse(q.suspended)
    }

    func testSyncMethodsSentToSender() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
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
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
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
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
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
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
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
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
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
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        let frameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose())
        dispatcher.sendAsyncFrameset(frameset)

        try! q.step()

        XCTAssertEqual(frameset, sender.sentFramesets.last!)
    }

    // MARK: After-close tests

    func testFutureBlockingWaitOnProducesErrorAfterClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        dispatcher.blockingWaitOn(RMQQueueDeclareOk.self)

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try! q.step()
        XCTAssertEqual(RMQError.ChannelClosed.rawValue, delegate.lastChannelError?.code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError)")
    }

    func testFutureSyncMethodBlockingProducesErrorAfterClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        dispatcher.sendSyncMethodBlocking(MethodFixtures.queueDeclare("", options: []))

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try! q.step()
        XCTAssertEqual(RMQError.ChannelClosed.rawValue, delegate.lastChannelError?.code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError)")
    }

    func testFutureSyncMethodProducesErrorAfterClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        dispatcher.sendSyncMethod(MethodFixtures.queueDeclare("foo", options: []))

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try! q.step()
        XCTAssertEqual(RMQError.ChannelClosed.rawValue, delegate.lastChannelError?.code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError)")
    }
    
    func testSendAsyncFramesetProducesErrorAfterClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        dispatcher.sendAsyncFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicDeliver()))

        XCTAssertEqual(1, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try! q.step()
        XCTAssertEqual(RMQError.ChannelClosed.rawValue, delegate.lastChannelError?.code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError)")
    }

    func testCloseOkSwallowsFutureSyncResponseErrors() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.sendSyncMethod(MethodFixtures.queueDeclare("", options: []))
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()                   // run close-ok expectation block
        try! q.step()                   // send queue.declare
        delegate.lastChannelError = nil // above causes error so reset
        try! q.step()                   // run queue.declare-ok expectation block
        XCTAssertNil(delegate.lastChannelError)
    }
    
    func testCloseOkStopsFutureSyncCompletionHandlersFromExecuting() {
        let (dispatcher, q, _) = setUpAfterCloseTest()
        var called = false
        dispatcher.sendSyncMethod(MethodFixtures.basicConsume("", consumerTag: "", options: [])) { result in
            called = true
        }
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()                   // run close-ok expectation block
        try! q.step()                   // send basic.consume
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicConsumeOk("")))
        try! q.step()                   // run basic.consume-ok response block
        XCTAssertFalse(called)
    }

    func testCloseDoesNotCauseErrorIfNotTheFirstOperation() {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendSyncMethod(MethodFixtures.channelOpen())
        dispatcher.sendSyncMethod(MethodFixtures.channelClose())

        try! q.step()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpenOk()))
        try! q.step()

        try! q.step()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    // MARK: Helpers

    func setUpAfterCloseTest() -> (dispatcher: RMQSuspendResumeDispatcher, q: FakeSerialQueue, delegate: ConnectionDelegateSpy) {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q)
        dispatcher.activateWithChannel(ch, delegate: delegate)

        dispatcher.sendSyncMethod(MethodFixtures.channelClose())
        try! q.step()

        return (dispatcher, q, delegate)
    }

}
