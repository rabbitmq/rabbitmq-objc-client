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

class RMQConnectionRecoverTest: XCTestCase {

    func testShutsDownHeartbeatSender() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: heartbeatSender,
                                           command: q,
                                           delegate: ConnectionDelegateSpy())
        recover?.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)

        try? q.step()
        XCTAssert(heartbeatSender.stopReceived)
    }

    func testRestartsConnectionAfterConfiguredDelay() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           command: q,
                                           delegate: ConnectionDelegateSpy())
        recover?.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)
        XCTAssertEqual(1, q.delayedItems.count)
        XCTAssertEqual(3, q.enqueueDelay)

        try? q.step()
        try? q.step()

        XCTAssertEqual(1, q.pendingItemsCount(), "Everything after interval must be enqueued in interval enqueue block")
        XCTAssertNil(conn.startCompletionHandler)
        try? q.step()
        XCTAssertNotNil(conn.startCompletionHandler)
    }

    func testRecoversChannelsKeptByAllocator() {
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let conn = StarterSpy()
        let recover = RMQConnectionRecover(interval: 3,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           command: q,
                                           delegate: ConnectionDelegateSpy())
        let ch0 = allocator.allocate() as! ChannelSpy
        let ch1 = allocator.allocate() as! ChannelSpy
        let ch2 = allocator.allocate() as! ChannelSpy
        let ch3 = allocator.allocate() as! ChannelSpy
        allocator.releaseChannelNumber(2)

        recover?.recover(conn, channelAllocator: allocator, error: nil)
        try! q.finish()

        XCTAssertFalse(ch0.recoverCalled)
        XCTAssertFalse(ch1.recoverCalled)
        XCTAssertFalse(ch2.recoverCalled)
        XCTAssertFalse(ch3.recoverCalled)

        XCTAssertEqual(0, q.pendingItemsCount())
        conn.startCompletionHandler!()

        try? q.step()

        XCTAssertFalse(ch0.recoverCalled)
        XCTAssertFalse(ch2.recoverCalled)

        XCTAssertTrue(ch1.recoverCalled)
        XCTAssertTrue(ch3.recoverCalled)
    }

    func testSendsMessagesToDelegateThroughoutCycle() {
        let conn = StarterSpy()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 1,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           command: q,
                                           delegate: delegate)
        recover?.recover(conn, channelAllocator: ChannelSpyAllocator(), error: nil)

        try? q.step()

        XCTAssertNil(delegate.willStartRecoveryConnection)

        try? q.step()

        XCTAssertEqual(conn, delegate.willStartRecoveryConnection!)
        XCTAssertNil(delegate.startingRecoveryConnection)

        try? q.step()

        XCTAssertEqual(conn, delegate.startingRecoveryConnection!)
        XCTAssertNil(delegate.recoveredConnection)

        conn.startCompletionHandler!()

        try? q.step()

        XCTAssertEqual(conn, delegate.recoveredConnection!)
    }

    func testDoesNotAttemptRestartAfterReachingAttemptLimit() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: false,
                                           heartbeatSender: heartbeatSender,
                                           command: q,
                                           delegate: delegate)
        recover?.recover(nil, channelAllocator: nil, error: nil)
        try! q.finish()
        recover?.recover(nil, channelAllocator: nil, error: nil)
        try! q.finish()
        delegate.willStartRecoveryConnection = nil
        heartbeatSender.stopReceived = false

        recover?.recover(StarterSpy(), channelAllocator: nil, error: nil)

        try? q.step()

        XCTAssert(heartbeatSender.stopReceived)
        XCTAssertNil(delegate.willStartRecoveryConnection)
        XCTAssertEqual(0, q.pendingItemsCount())
    }

    func testZeroDelaySignifiesNoRecovery() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 0,
                                           attemptLimit: 2,
                                           onlyErrors: false,
                                           heartbeatSender: heartbeatSender,
                                           command: q,
                                           delegate: delegate)
        recover?.recover(StarterSpy(), channelAllocator: nil, error: nil)

        try? q.step()

        XCTAssert(heartbeatSender.stopReceived)
        XCTAssertNil(delegate.willStartRecoveryConnection)
        XCTAssertEqual(0, q.pendingItemsCount())
    }

    func testAttemptLimitIsResetAfterSuccessfulRecovery() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: false,
                                           heartbeatSender: HeartbeatSenderSpy(),
                                           command: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover?.recover(conn, channelAllocator: nil, error: nil)

        try? q.step()                  // stop heartbeats
        try? q.step()                  // attempt connection start, never completes

        recover?.recover(conn, channelAllocator: nil, error: nil)

        try? q.step()                  // stop heartbeats
        try? q.step()                  // attempt connection start

        conn.startCompletionHandler!() // this time handshake completes
        try? q.step()                  // run queued after-handshake work

        let queueLengthBefore = q.items.count
        recover?.recover(conn, channelAllocator: nil, error: nil)

        XCTAssertGreaterThan(q.items.count, queueLengthBefore)
    }

    func testDoesNotRestartConnectionIfNoErrorAndConfiguredToOnlyRecoverErrors() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: true,
                                           heartbeatSender: heartbeatSender,
                                           command: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover?.recover(conn, channelAllocator: nil, error: nil)

        try? q.step()
        XCTAssert(heartbeatSender.stopReceived)

        XCTAssertEqual(0, q.pendingItemsCount())
    }

    func testRestartsConnectionIfErrorReceivedAndConfiguredToOnlyRecoverErrors() {
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let heartbeatSender = HeartbeatSenderSpy()
        let recover = RMQConnectionRecover(interval: 10,
                                           attemptLimit: 2,
                                           onlyErrors: true,
                                           heartbeatSender: heartbeatSender,
                                           command: q,
                                           delegate: delegate)
        let conn = StarterSpy()
        recover?.recover(conn, channelAllocator: nil, error: NSError(domain: RMQErrorDomain, code: 999, userInfo: [:]))

        try? q.step()
        XCTAssert(heartbeatSender.stopReceived)

        try? q.step()
        try? q.step()
        XCTAssertNotNil(conn.startCompletionHandler)
    }

}
