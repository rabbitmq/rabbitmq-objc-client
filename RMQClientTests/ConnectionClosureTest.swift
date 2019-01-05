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

class ConnectionClosureTest: XCTestCase {
    func testCloseClosesAllChannels() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let handshakeCount = 1
        let expectedCloseProcedureCount = 5
        let channelsToCreateCount = 2
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 2,
                                 channelAllocator: allocator,
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())

        conn.start()
        try? q.step()
        transport.handshake()

        for _ in 1...channelsToCreateCount {
            conn.createChannel()
        }

        conn.close()

        for _ in 1...channelsToCreateCount {
            try? q.step()
        }

        XCTAssertEqual(handshakeCount + channelsToCreateCount + expectedCloseProcedureCount, q.items.count)

        try? q.step()

        XCTAssertFalse(allocator.channels[0].blockingCloseCalled)
        XCTAssertTrue(allocator.channels[1].blockingCloseCalled)
        XCTAssertTrue(allocator.channels[2].blockingCloseCalled)
    }

    func testCloseSendsCloseMethod() {
        let (transport, q, conn, _) = ConnectionWithFakesHelper.connectionAfterHandshake()

        conn.close()

        try? q.step()
        try? q.step()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
    }

    func testCloseWaitsForCloseOkOnChannelZero() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 2,
                                 channelAllocator: allocator,
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())
        // start connection
        conn.start()

        /// simulate connection has been made
        try? q.step()
        transport.handshake()

        conn.close()

        try? q.step()
        try? q.step()

        XCTAssertNil(allocator.channels[0].blockingWaitOnMethod)
        try? q.step()
        XCTAssertEqual("RMQConnectionCloseOk", allocator.channels[0].blockingWaitOnMethod?.description())
    }

    func testCloseShutsDownHeartbeatSender() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 2,
                                 channelAllocator: allocator,
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)

        conn.start()
        conn.close()

        try? q.step()
        try? q.step()
        try? q.step()

        XCTAssertFalse(heartbeatSender.stopReceived)
        try? q.step()
        XCTAssertTrue(heartbeatSender.stopReceived)
    }

    func testCloseClosesTransportAndSetsItsDelegateToNil() {
        let numCloseOpsBeforeTransportClose = 4
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let heartbeatSender = HeartbeatSenderSpy()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 2,
                                 channelAllocator: allocator,
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        conn.start()
        try? q.step()
        transport.handshake()

        conn.close()

        for _ in 1...numCloseOpsBeforeTransportClose {
            try? q.step()
        }

        XCTAssertTrue(transport.connected)
        XCTAssertEqual(conn, transport.delegate as? RMQConnection)
        try? q.step()
        XCTAssertFalse(transport.connected)
        XCTAssertNil(transport.delegate)
    }

    func testBlockingCloseIsANormalCloseButBlocking() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let expectedCloseProcedureCount = 5
        let channelsToCreateCount = 2
        let heartbeatSender = HeartbeatSenderSpy()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionWithFakesHelper.connectionConfig(),
                                 handshakeTimeout: 2,
                                 channelAllocator: allocator,
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 command: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)

        conn.start()
        try? q.step()
        transport.handshake()

        for _ in 1...channelsToCreateCount {
            conn.createChannel()
        }

        conn.blockingClose()

        for _ in 1...channelsToCreateCount {
            try? q.step()
        }

        XCTAssertEqual(expectedCloseProcedureCount, q.blockingItems.count)

        try? q.step()

        XCTAssertFalse(allocator.channels[0].blockingCloseCalled)
        XCTAssertTrue(allocator.channels[1].blockingCloseCalled)
        XCTAssertTrue(allocator.channels[2].blockingCloseCalled)

        try? q.step()

        XCTAssertEqual(MethodFixtures.connectionClose(), transport.lastSentPayload() as? RMQConnectionClose)

        try? q.step()

        XCTAssertEqual("RMQConnectionCloseOk", allocator.channels[0].blockingWaitOnMethod!.description())

        try? q.step()

        XCTAssertTrue(heartbeatSender.stopReceived)

        try? q.step()

        XCTAssertFalse(transport.connected)
    }

    func testServerInitiatedClosureDisconnectsTransportButKeepsConnectionAsDelegateToAllowRecovery() {
        let (transport, _, conn, _) = ConnectionWithFakesHelper.connectionAfterHandshake()

        transport.delegate = nil // this actually happens in the transport, which is fake here
        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelNumber: 0)

        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertEqual(conn, transport.delegate as? RMQConnection)
    }

}
