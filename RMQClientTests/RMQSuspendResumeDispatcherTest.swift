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
        let (dispatcher, q, sender, _, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGet())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testSyncMethodFailureSendsErrorToDelegate() {
        let (dispatcher, q, _, delegate, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())
        try! q.step()

        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))
        try! q.step()

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError!.code)
    }

    func testBlockingSyncMethodsSentToSender() {
        let (dispatcher, q, sender, delegate, ch) = setupActivated()

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
        let (dispatcher, q, _, delegate, _) = setupActivated()

        dispatcher.sendSyncMethodBlocking(MethodFixtures.basicGet())

        try! q.step()
        try! q.step()

        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))

        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, delegate.lastChannelError!.code)
    }
    
    func testAsyncMethodSendsFrameset() {
        let (dispatcher, q, sender, _, _) = setupActivated()

        dispatcher.sendAsyncMethod(MethodFixtures.channelOpen())

        try! q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpen())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testAsyncFramesetSendsFrameset() {
        let (dispatcher, q, sender, _, _) = setupActivated()

        let frameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicAck(1, options: []))
        dispatcher.sendAsyncFrameset(frameset)

        try! q.step()

        XCTAssertEqual(frameset, sender.sentFramesets.last!)
    }

    // MARK: Client close tests

    func testFutureBlockingWaitOnProducesErrorAfterClientClose() {
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

    func testFutureSyncMethodBlockingProducesErrorAfterClientClose() {
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

    func testFutureSyncMethodProducesErrorAfterClientClose() {
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
    
    func testSendAsyncFramesetProducesErrorAfterClientClose() {
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
        let (dispatcher, q, _, delegate, _) = setupActivated()

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

    func testAdditionalClientClosuresHaveNoEffect() {
        let (dispatcher, q, sender, delegate, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.channelClose())
        try! q.step()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try! q.step()

        sender.lastSentMethod = nil
        dispatcher.sendSyncMethodBlocking(MethodFixtures.channelClose())
        try! q.step()

        XCTAssertNil(delegate.lastChannelError)
        XCTAssertNil(sender.lastSentMethod)
    }

    // MARK: Server close tests

    func testServerCloseCausesCloseOkToBeSentInResponse() {
        let (dispatcher, _, sender, _, _) = setupActivated()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        XCTAssertEqual(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()),
                       sender.sentFramesets.last)
    }

    func testServerCloseStopsFutureConsumersFromTriggering() {
        let (dispatcher, q, _, _, _) = setupActivated()
        var called = false
        dispatcher.sendSyncMethod(MethodFixtures.basicConsume("", consumerTag: "", options: [])) { result in
            called = true
        }
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))

        try! q.step()                   // send basic.consume
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicConsumeOk("")))
        try! q.step()                   // run basic.consume-ok response block
        XCTAssertFalse(called)
    }

    func testServerCloseSendsErrorToDelegateWithCloseReasonWhen404() {
        let (dispatcher, _, _, delegate, _) = setupActivated()
        let close = RMQChannelClose(
            replyCode: RMQShort(404),
            replyText: RMQShortstr("NOT_FOUND - no exchange 'yomoney' in vhost '/'"),
            classId: RMQShort(60),
            methodId: RMQShort(40)
        )
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: close))
        XCTAssertEqual(RMQError.NotFound.rawValue, delegate.lastChannelError?.code)
        XCTAssertEqual("NOT_FOUND - no exchange 'yomoney' in vhost '/'", delegate.lastChannelError?.localizedDescription)
    }

    func testServerCloseTriggersErrorsForFutureOperations() {
        let (dispatcher, q, _, delegate, _) = setupActivated()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        dispatcher.sendSyncMethod(MethodFixtures.basicGet())
        delegate.lastChannelError = nil
        try! q.step()
        XCTAssertEqual(RMQError.ChannelClosed.rawValue, delegate.lastChannelError?.code)
    }

    func testServerCloseResumesCommandQueueToAllowErrorsToPropagate() {
        let (dispatcher, q, _, _, _) = setupActivated()
        q.suspend()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        XCTAssertFalse(q.suspended)
    }

    func testClientCloseFollowingServerCloseHasNoEffect() {
        let (dispatcher, q, sender, delegate, _) = setupActivated()
        dispatcher.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))

        delegate.lastChannelError = nil
        sender.lastSentMethod = nil
        dispatcher.sendSyncMethodBlocking(MethodFixtures.channelClose())
        try! q.finish()

        XCTAssertNil(delegate.lastChannelError)
        XCTAssertNil(sender.lastSentMethod)
    }

    // MARK: Helpers

    func setupActivated() -> (dispatcher: RMQSuspendResumeDispatcher, q: FakeSerialQueue, sender: SenderSpy, delegate: ConnectionDelegateSpy, ch: RMQAllocatedChannel) {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, commandQueue: q)
        let ch = RMQAllocatedChannel(123, contentBodySize: 1, dispatcher: dispatcher, commandQueue: q, nameGenerator: StubNameGenerator(), allocator: ChannelSpyAllocator())
        dispatcher.activateWithChannel(ch, delegate: delegate)
        return (dispatcher, q, sender, delegate, ch)
    }

    func setUpAfterCloseTest() -> (dispatcher: RMQSuspendResumeDispatcher, q: FakeSerialQueue, delegate: ConnectionDelegateSpy) {
        let (dispatcher, q, _, delegate, _) = setupActivated()
        dispatcher.sendSyncMethod(MethodFixtures.channelClose())
        try! q.step()
        return (dispatcher, q, delegate)
    }

}
