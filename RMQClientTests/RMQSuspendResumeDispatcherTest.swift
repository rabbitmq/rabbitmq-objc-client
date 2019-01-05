// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 1.1 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2019 Pivotal Software, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v1.1:
//
// ---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is RabbitMQ
//
// The Initial Developer of the Original Code is Pivotal Software, Inc.
// All Rights Reserved.
//
// Alternatively, the contents of this file may be used under the terms
// of the Apache Standard license (the "ASL License"), in which case the
// provisions of the ASL License are applicable instead of those
// above. If you wish to allow use of your version of this file only
// under the terms of the ASL License and not to allow others to use
// your version of this file under the MPL, indicate your decision by
// deleting the provisions above and replace them with the notice and
// other provisions required by the ASL License. If you do not delete
// the provisions above, a recipient may use your version of this file
// under either the MPL or the ASL License.
// ---------------------------------------------------------------------------

import XCTest

class RMQSuspendResumeDispatcherTest: XCTestCase {

    func testDelegatesEnqueueToCommandQueue() {
        let q = FakeSerialQueue()
        let dispatcher = RMQSuspendResumeDispatcher(sender: SenderSpy(), command: q)

        var enqueueCalled = false
        dispatcher?.enqueue {
            enqueueCalled = true
        }
        XCTAssertEqual(1, q.items.count)
        try? q.step()
        XCTAssert(enqueueCalled)
    }

    func testDisableSuspendsCommandQueueAndPreventsFramesetHandlingFromResuming() {
        let q = FakeSerialQueue()
        let eq = FakeSerialQueue()
        let dispatcher = RMQSuspendResumeDispatcher(sender: SenderSpy(), command: q,
                                                    enablementQueue: eq, enableDelay: 3)

        dispatcher?.disable()
        XCTAssertTrue(q.suspended)

        dispatcher?.handle(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        dispatcher?.enable()

        XCTAssertTrue(q.suspended)
        XCTAssertEqual(3, eq.enqueueDelay)
        try! eq.step()
        XCTAssertFalse(q.suspended)
    }

    func testActivatingResumesQueue() {
        let q = FakeSerialQueue()
        q.suspend()
        let dispatcher = RMQSuspendResumeDispatcher(sender: SenderSpy(), command: q)
        dispatcher?.activate(with: nil, delegate: nil)
        XCTAssertFalse(q.suspended)
    }

    func testSyncMethodsSentToSender() {
        let (dispatcher, q, sender, _, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())

        try? q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGet())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testSyncMethodFailureSendsErrorToDelegate() {
        let (dispatcher, q, _, delegate, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.basicGet())
        try? q.step()

        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))
        try? q.step()

        XCTAssertEqual(RMQError.channelIncorrectSyncMethod.rawValue, delegate.lastChannelError!._code)
    }

    func testBlockingSyncMethodsSentToSender() {
        let (dispatcher, q, sender, delegate, ch) = setupActivated()

        dispatcher.sendSyncMethodBlocking(MethodFixtures.basicGet())
        XCTAssertEqual(2, q.blockingItems.count)
        try? q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGet())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)

        ch.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicGetOk(routingKey: "foo")))
        try? q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testBlockingErrorsSentToDelegate() {
        let (dispatcher, q, _, delegate, _) = setupActivated()

        dispatcher.sendSyncMethodBlocking(MethodFixtures.basicGet())

        try? q.step()
        try? q.step()

        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicQosOk()))

        XCTAssertEqual(RMQError.channelIncorrectSyncMethod.rawValue, delegate.lastChannelError!._code)
    }

    func testAsyncMethodSendsFrameset() {
        let (dispatcher, q, sender, _, _) = setupActivated()

        dispatcher.sendAsyncMethod(MethodFixtures.channelOpen())

        try? q.step()

        let expectedFrameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpen())
        XCTAssertEqual(expectedFrameset, sender.sentFramesets.last!)
    }

    func testAsyncFramesetSendsFrameset() {
        let (dispatcher, q, sender, _, _) = setupActivated()

        let frameset = RMQFrameset(channelNumber: 123, method: MethodFixtures.basicAck(1, options: []))
        dispatcher.sendAsyncFrameset(frameset)

        try? q.step()

        XCTAssertEqual(frameset, sender.sentFramesets.last!)
    }

    // MARK: Client-initiated channel.close tests

    func testFutureBlockingWaitOnProducesErrorAfterClientClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        dispatcher.blockingWait(on: RMQQueueDeclareOk.self)

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try? q.step()
        XCTAssertEqual(RMQError.channelClosed.rawValue, delegate.lastChannelError?._code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError!)")
    }

    func testFutureSyncMethodBlockingProducesErrorAfterClientClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        dispatcher.sendSyncMethodBlocking(MethodFixtures.queueDeclare("", options: []))

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try? q.step()
        XCTAssertEqual(RMQError.channelClosed.rawValue, delegate.lastChannelError?._code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError!)")
    }

    func testFutureSyncMethodProducesErrorAfterClientClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        dispatcher.sendSyncMethod(MethodFixtures.queueDeclare("foo", options: []))

        XCTAssertEqual(2, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try? q.step()
        XCTAssertEqual(RMQError.channelClosed.rawValue, delegate.lastChannelError?._code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError!)")
    }

    func testSendAsyncFramesetProducesErrorAfterClientClose() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        dispatcher.sendAsyncFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicDeliver()))

        XCTAssertEqual(1, q.pendingItemsCount(),
                       "Not queuing the is-already-closed check (probably checking immediately by accident).")
        try? q.step()
        XCTAssertEqual(RMQError.channelClosed.rawValue, delegate.lastChannelError?._code,
                       "Didn't receive correct error\nGot: \(delegate.lastChannelError!)")
    }

    func testReceivingCloseOkSwallowsFutureSyncResponseErrors() {
        let (dispatcher, q, delegate) = setUpAfterCloseTest()
        dispatcher.sendSyncMethod(MethodFixtures.queueDeclare("", options: []))
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()                   // run close-ok expectation block
        try? q.step()                   // send queue.declare
        delegate.lastChannelError = nil // above causes error so reset
        try? q.step()                   // run queue.declare-ok expectation block
        XCTAssertNil(delegate.lastChannelError)
    }

    func testReceivingChannelCloseOkStopsFutureSyncCompletionHandlersFromExecuting() {
        let (dispatcher, q, _) = setUpAfterCloseTest()
        var called = false
        dispatcher.sendSyncMethod(MethodFixtures.basicConsume("", consumerTag: "", options: [])) { _ in
            called = true
        }
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()                   // run close-ok expectation block
        try? q.step()                   // send basic.consume
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicConsumeOk("")))
        try? q.step()                   // run basic.consume-ok response block
        XCTAssertFalse(called)
    }

    func testChannelCloseDoesNotCauseErrorIfNotTheFirstOperation() {
        let (dispatcher, q, _, delegate, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.channelOpen())
        dispatcher.sendSyncMethod(MethodFixtures.channelClose())

        try? q.step()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelOpenOk()))
        try? q.step()

        try? q.step()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        XCTAssertNil(delegate.lastChannelError)
    }

    func testRepeatedChannelClosuresHaveNoEffect() {
        let (dispatcher, q, sender, delegate, _) = setupActivated()

        dispatcher.sendSyncMethod(MethodFixtures.channelClose())
        try? q.step()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()))
        try? q.step()

        sender.lastSentMethod = nil
        dispatcher.sendSyncMethodBlocking(MethodFixtures.channelClose())
        try? q.step()

        XCTAssertNil(delegate.lastChannelError)
        XCTAssertNil(sender.lastSentMethod)
    }

    func testClientCloseFollowingServerCloseHasNoEffect() {
        let (dispatcher, q, sender, delegate, _) = setupActivated()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))

        delegate.lastChannelError = nil
        sender.lastSentMethod = nil
        dispatcher.sendSyncMethodBlocking(MethodFixtures.channelClose())
        try! q.finish()

        XCTAssertNil(delegate.lastChannelError)
        XCTAssertNil(sender.lastSentMethod)
    }

    // MARK: Server-sent channel.close tests

    func testServerSentChannelCloseCausesCloseOkToBeSentInResponse() {
        let (dispatcher, _, sender, _, _) = setupActivated()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        XCTAssertEqual(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelCloseOk()),
                       sender.sentFramesets.last)
    }

    func testServerSentChannelCloseStopsFutureConsumersFromTriggering() {
        let (dispatcher, q, _, _, _) = setupActivated()
        var called = false
        dispatcher.sendSyncMethod(MethodFixtures.basicConsume("", consumerTag: "", options: [])) { _ in
            called = true
        }
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))

        try? q.step()                   // send basic.consume
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicConsumeOk("")))
        try? q.step()                   // run basic.consume-ok response block
        XCTAssertFalse(called)
    }

    func testServerSentChannelCloseSendsErrorToDelegateWithCloseReasonWhen404() {
        let (dispatcher, _, _, delegate, _) = setupActivated()
        let close = RMQChannelClose(
            replyCode: RMQShort(404),
            replyText: RMQShortstr("NOT_FOUND - no exchange 'yomoney' in vhost '/'"),
            classId: RMQShort(60),
            methodId: RMQShort(40)
        )
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: close))
        XCTAssertEqual(RMQError.notFound.rawValue, delegate.lastChannelError?._code)
        XCTAssertEqual("NOT_FOUND - no exchange 'yomoney' in vhost '/'",
                       delegate.lastChannelError?.localizedDescription)
    }

    func testServerSentChannelCloseTriggersErrorsForFutureOperations() {
        let (dispatcher, q, _, delegate, _) = setupActivated()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        dispatcher.sendSyncMethod(MethodFixtures.basicGet())
        delegate.lastChannelError = nil
        try? q.step()
        XCTAssertEqual(RMQError.channelClosed.rawValue, delegate.lastChannelError?._code)
    }

    func testServerSentChannelCloseResumesCommandQueueToAllowErrorsToPropagate() {
        let (dispatcher, q, _, _, _) = setupActivated()
        q.suspend()
        dispatcher.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.channelClose()))
        XCTAssertFalse(q.suspended)
    }

    // MARK: Helpers

    func setupActivated() -> (dispatcher: RMQSuspendResumeDispatcher, q: FakeSerialQueue, sender: SenderSpy,
                              delegate: ConnectionDelegateSpy, ch: RMQAllocatedChannel) {
        let q = FakeSerialQueue()
        let sender = SenderSpy()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = RMQSuspendResumeDispatcher(sender: sender, command: q)
        let ch = ChannelHelper.makeChannel(123, contentBodySize: 1, dispatcher: dispatcher!)
        dispatcher?.activate(with: ch, delegate: delegate)
        return (dispatcher!, q, sender, delegate, ch)
    }

    func setUpAfterCloseTest() -> (dispatcher: RMQSuspendResumeDispatcher, q: FakeSerialQueue,
                                   delegate: ConnectionDelegateSpy) {
        let (dispatcher, q, _, delegate, _) = setupActivated()
        dispatcher.sendSyncMethod(MethodFixtures.channelClose())
        try? q.step()
        return (dispatcher, q, delegate)
    }

}
