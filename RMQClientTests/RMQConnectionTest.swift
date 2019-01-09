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

class RMQConnectionTest: XCTestCase {
    func testCallsCompletionHandlerWhenHandshakeComplete() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(
            transport: transport,
            config: ConnectionWithFakesHelper.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            command: q,
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        var called = false
        conn.start { called = true }
        try? q.step()
        XCTAssertFalse(called)
        transport.handshake()
        XCTAssert(called)
    }

    func testImmediateConnectionErrorIsSentToDelegate() {
        let transport = ControlledInteractionTransport()
        transport.stubbedToThrowErrorOnConnect = "bad connection"
        let delegate = ConnectionDelegateSpy()
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        let conn = RMQConnection(
            transport: transport,
            config: ConnectionWithFakesHelper.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: allocator!,
            frameHandler: allocator!,
            delegate: delegate,
            command: FakeSerialQueue(),
            waiterFactory: RMQSemaphoreWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        XCTAssertNil(delegate.lastConnectionError)
        conn.start()
        XCTAssertEqual("bad connection", delegate.lastConnectionError!.localizedDescription)
    }

    func testErrorSentToDelegateOnHandshakeTimeout() {
        let transport = ControlledInteractionTransport()
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 10)
        let delegate = ConnectionDelegateSpy()
        let q = FakeSerialQueue()
        let conn = RMQConnection(
            transport: transport,
            config: ConnectionWithFakesHelper.connectionConfig(),
            handshakeTimeout: 0,
            channelAllocator: allocator!,
            frameHandler: allocator!,
            delegate: delegate,
            command: q,
            waiterFactory: RMQSemaphoreWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.start()
        try? q.step()

        XCTAssertEqual("Handshake timed out.", delegate.lastConnectionError?.localizedDescription)
    }

    func testTransportDelegateDisconnectErrorsAreTransformedIntoConnectionDelegateErrors() {
        let transport = ControlledInteractionTransport()
        let delegate = ConnectionDelegateSpy()
        let conn = ConnectionWithFakesHelper.startedConnection(transport, delegate: delegate)
        let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "foo"])

        conn.transport(nil, disconnectedWithError: e)

        XCTAssertEqual("foo", delegate.lastDisconnectError!.localizedDescription)
    }

    func testTransportDisconnectNotificationsNotTransformedWhenCloseRequested() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        conn.close()
        conn.transport(nil, disconnectedWithError: nil)

        XCTAssertFalse(delegate.disconnectCalled)
    }

    func testTransportDisconnectErrorTriggersRecovery() {
        let transport = ControlledInteractionTransport()
        let recovery = RecoverySpy()
        let allocator = ChannelSpyAllocator()
        let error = NSError(domain: RMQErrorDomain, code: RMQError.connectionHandshakeTimedOut.rawValue,
                            userInfo: [:])
        let conn = RMQConnection(
            transport: transport,
            config: recovery.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            command: FakeSerialQueue(),
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.transport(transport, disconnectedWithError: error)

        XCTAssertEqual(conn, recovery.connectionPassedToRecover as? RMQConnection)
        XCTAssertEqual(allocator, recovery.allocatorPassedToRecover as? ChannelSpyAllocator)
        XCTAssertEqual(error, recovery.errorPassedToRecover! as NSError)
    }

    func testTransportDisconnectMessageWithoutErrorTriggersRecovery() {
        let transport = ControlledInteractionTransport()
        let recovery = RecoverySpy()
        let allocator = ChannelSpyAllocator()
        let conn = RMQConnection(
            transport: transport,
            config: recovery.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            command: FakeSerialQueue(),
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.transport(transport, disconnectedWithError: nil)

        XCTAssertEqual(conn, recovery.connectionPassedToRecover as? RMQConnection)
        XCTAssertEqual(allocator, recovery.allocatorPassedToRecover as? ChannelSpyAllocator)
        XCTAssertNil(recovery.errorPassedToRecover)
    }

    func testSignalsActivityToHeartbeatSenderOnOutgoingFrameset() {
        let heartbeatSender = HeartbeatSenderSpy()
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        conn.start()
        try? q.step()
        transport.handshake()

        heartbeatSender.signalActivityReceived = false

        conn.send(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()))

        XCTAssertEqual(MethodFixtures.channelOpen(), transport.lastSentPayload() as? RMQChannelOpen)
        XCTAssert(heartbeatSender.signalActivityReceived)
    }

    func testDoesNotSendFramesOrSignalToHeartbeatWhenInRecovery() {
        let heartbeatSender = HeartbeatSenderSpy()
        let recovery = RecoverySpy()
        let q = FakeSerialQueue()
        let transport = ControlledInteractionTransport()
        let conn = RMQConnection(transport: transport,
                                 config: recovery.connectionConfig(),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        recovery.interval = 1
        conn.start()
        try? q.step()
        // handshake not yet complete, simulating recovery mode

        transport.outboundData = []

        conn.send(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()))

        XCTAssertFalse(heartbeatSender.signalActivityReceived)
        XCTAssertEqual(0, transport.outboundData.count)
        XCTAssertEqual(0, q.pendingItemsCount())
    }

    func testSendsVersionNumberWithStartOk() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(vhost: ""),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())
        conn.start()
        try? q.step()

        transport.serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)

        let parser = RMQParser(data: transport.outboundData.last! as Data)
        let outgoingStartOk: RMQConnectionStartOk = RMQFrame(parser: parser).payload as! RMQConnectionStartOk

        XCTAssert(outgoingStartOk.description.range(of: TestHelper.frameworkVersion()) != nil)
    }

    func testSendsConfiguredVHostWithConnectionOpen() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(vhost: "/myvhost"),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())
        conn.start()
        try? q.step()

        transport.handshake()

        let parser = RMQParser(data: transport.outboundData.last! as Data)
        let outgoingConnectionOpen: RMQConnectionOpen = RMQFrame(parser: parser).payload as! RMQConnectionOpen

        XCTAssertEqual("/myvhost", outgoingConnectionOpen.virtualHost.stringValue)
    }

    func testSpecialCharsInURISendsErrorToDelegate() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(uri: "amqps://other:wise@valid`oops", delegate: delegate)
        conn.start()
        XCTAssert(TestHelper.pollUntil { delegate.lastConnectionError != nil },
                  "Timed out waiting for a connection error with invalid URI")
    }

}
