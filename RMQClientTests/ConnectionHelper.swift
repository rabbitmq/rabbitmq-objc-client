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

class ConnectionHelper {
    static let defaultUsername = "guest"
    static let defaultPassword = "guest"

    static func makeConnection(recoveryInterval
                               interval: Int = 2,
                               onlyErrors: Bool = true,
                               attemptLimit: Int = 1,
                               transport: RMQTCPSocketTransport,
                               delegate: RMQConnectionDelegate) -> RMQConnection {
        let credentials = RMQCredentials(username: defaultUsername, password: defaultPassword)
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 10)
        let heartbeatSender = RMQGCDHeartbeatSender(transport: transport, clock: RMQTickingClock())
        let commandQueue = RMQGCDSerialQueue(name: "socket-recovery-test-queue")
        let recovery = RMQConnectionRecover(interval: interval as NSNumber,
                                            attemptLimit: attemptLimit as NSNumber,
                                            onlyErrors: onlyErrors,
                                            heartbeatSender: heartbeatSender,
                                            command: commandQueue,
                                            delegate: delegate)
        let config = RMQConnectionConfig(credentials: credentials,
                                         channelMax: RMQChannelMaxDefault as NSNumber,
                                         frameMax: RMQFrameMax as NSNumber,
                                         heartbeat: 60,
                                         vhost: "/",
                                         authMechanism: "PLAIN",
                                         recovery: recovery!)
        return RMQConnection(transport: transport,
                             config: config,
                             handshakeTimeout: 10,
                             channelAllocator: allocator!,
                             frameHandler: allocator!,
                             delegate: delegate,
                             command: commandQueue!,
                             waiterFactory: RMQSemaphoreWaiterFactory(),
                             heartbeatSender: heartbeatSender!)
    }
}
