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

class ConnectionTuningTest: XCTestCase {
    func testUsesClientTuneOptionsWhenServersAreZeroes() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 12, 10, 9)

        XCTAssertEqual(
            clientTuneOk(
                RMQShort(12), RMQLong(10), RMQShort(9)
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(0), RMQLong(0), RMQShort(0)
            )
        )
    }

    func testUsesServerTuneOptionsWhenClientsAreZeroes() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 0, 0, 0)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(12), RMQLong(10), RMQShort(9)
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(12), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testUsesClientTuneOptionsWhenServersAreHigher() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 11, 9, 8)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(11), RMQLong(9), RMQShort(8)
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(12), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testUsesServerTuneOptionsWhenClientsAreHigher() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 12, 11, 10)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(11), RMQLong(10), RMQShort(9)
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(11), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testSetsHalfOfNegotiatedHeartbeatTimeoutAsHeartbeatInterval() {
        let transport = ControlledInteractionTransport()
        let heartbeatSender = HeartbeatSenderSpy()
        let q = connectWithOptions(transport, 1, 1, 100, heartbeatSender: heartbeatSender)
        XCTAssertNil(heartbeatSender.heartbeatIntervalReceived)
        negotiatedParamsGivenServerParams(transport, q,
                                          RMQShort(11), RMQLong(10), RMQShort(0))
        XCTAssertEqual(50, heartbeatSender.heartbeatIntervalReceived)
    }

    // MARK: Helpers

    func connectWithOptions(_ transport: ControlledInteractionTransport,
                            _ channelMax: Int, _ frameMax: UInt, _ heartbeat: Int,
                            heartbeatSender: RMQHeartbeatSender = HeartbeatSenderSpy()) -> FakeSerialQueue {
        let q = FakeSerialQueue()
        let connection = RMQConnection(
            transport: transport,
            config: ConnectionWithFakesHelper.connectionConfig(channelMax: channelMax,
                                                               frameMax: frameMax, heartbeat: heartbeat),
            handshakeTimeout: 10,
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: nil,
            command: q,
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: heartbeatSender
        )
        connection.start()
        try? q.step()
        return q
    }

    func clientTuneOk(_ channelMax: RMQShort, _ frameMax: RMQLong, _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
        return RMQConnectionTuneOk(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat)
    }

    @discardableResult
    func negotiatedParamsGivenServerParams(_ transport: ControlledInteractionTransport,
                                           _ q: FakeSerialQueue,
                                           _ channelMax: RMQShort,
                                           _ frameMax: RMQLong,
                                           _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
        let tune = RMQConnectionTune(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat)

        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
            .serverSendsPayload(tune, channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)

        let parser = RMQParser(data: transport.outboundData[transport.outboundData.count - 2] as Data)
        let frame = RMQFrame(parser: parser)
        return frame.payload as! RMQConnectionTuneOk
    }
}
