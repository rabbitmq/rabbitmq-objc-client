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

class ConnectionWithFakesHelper {
    static func makeConnection(_ recoveryInterval: Int = 2,
                               channelAllocator: RMQChannelAllocator = ChannelSpyAllocator(),
                               config: RMQConnectionConfig = RMQConnectionConfig(),
                               commandQueue: RMQLocalSerialQueue = FakeSerialQueue(),
                               transport: RMQTransport = ControlledInteractionTransport(),
                               frameHandler: RMQFrameHandler = FrameHandlerSpy(),
                               waiterFactory: RMQWaiterFactory = FakeWaiterFactory(),
                               heartbeatSender: RMQHeartbeatSender = HeartbeatSenderSpy(),
                               delegate: RMQConnectionDelegate = ConnectionDelegateSpy()) -> RMQConnection {
        return RMQConnection(
            transport: transport,
            config: config,
            handshakeTimeout: 10,
            channelAllocator: channelAllocator,
            frameHandler: frameHandler,
            delegate: delegate,
            command: commandQueue,
            waiterFactory: waiterFactory,
            heartbeatSender: heartbeatSender
        )
    }

    static func connectionConfig(vhost: String = "",
                                 channelMax: Int = 123,
                                 frameMax: UInt = 321,
                                 heartbeat: Int = 10) -> RMQConnectionConfig {
        let nullRecovery = RMQConnectionRecover(interval: 0,
                                                attemptLimit: 0,
                                                onlyErrors: true,
                                                heartbeatSender: nil,
                                                command: nil,
                                                delegate: nil)
        return RMQConnectionConfig(credentials: RMQCredentials(username: "foo", password: "bar"),
                                   channelMax: channelMax as NSNumber,
                                   frameMax: frameMax as NSNumber,
                                   heartbeat: heartbeat as NSNumber,
                                   vhost: vhost,
                                   authMechanism: "PLAIN",
                                   recovery: nullRecovery!)
    }

    static func startedConnection(
        _ transport: RMQTransport,
        commandQueue: RMQLocalSerialQueue = RMQGCDSerialQueue(name: "started connection command queue"),
        delegate: RMQConnectionDelegate? = nil,
        syncTimeout: Double = 0,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        let config = connectionConfig(vhost: vhost,
                                      channelMax: RMQChannelMaxDefault,
                                      frameMax: RMQFrameMax,
                                      heartbeat: 0)
        let conn = RMQConnection(
            transport: transport,
            config: config,
            handshakeTimeout: 10,
            channelAllocator: allocator!,
            frameHandler: allocator!,
            delegate: delegate,
            command: commandQueue,
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.start()
        return conn
    }

    static func connectionAfterHandshake() -> (transport: ControlledInteractionTransport, q: FakeSerialQueue,
        conn: RMQConnection, delegate: ConnectionDelegateSpy) {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let conn = ConnectionWithFakesHelper.startedConnection(transport,
                                                               commandQueue: q,
                                                               delegate: delegate)
        try? q.step()
        transport.handshake()

        return (transport, q, conn, delegate)
    }
}
