// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 2.0 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2022 VMware, Inc. or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v2.0:
//
// ---------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2007-2022 VMware, Inc. or its affiliates.  All rights reserved.
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

class IntegrationHelper {
    static let defaultEndpoint: String = "amqp://guest:guest@127.0.0.1"
    static let defaultTimeout: Double = 10
    static let defaultNoCompletionTimeout: Double = 3

    static func createNamedConnection(_ name: String) -> RMQConnection {
        let gcdQueue = DispatchQueue(label: "com.rabbitmq.client.tests.\(name)")
        return RMQConnection(
                    uri: IntegrationHelper.defaultEndpoint,
                    userProvidedConnectionName: name,
                    delegate: nil,
                    delegateQueue: gcdQueue)
    }

    static func awaitCompletion(_ semaphore: DispatchSemaphore) -> DispatchTimeoutResult {
        return semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(defaultTimeout))
    }

    static func awaitCompletion(_ semaphore: DispatchSemaphore, timeout: Double) -> DispatchTimeoutResult {
        return semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(timeout))
    }

    static func awaitNoCompletion(_ semaphore: DispatchSemaphore) {
        let result = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(defaultNoCompletionTimeout))
        XCTAssertEqual(.timedOut, result, "Got an unexpected delivery")
    }

    static func awaitNoCompletion(_ semaphore: DispatchSemaphore, timeout: Double) {
        let result = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(timeout))
        XCTAssertEqual(.timedOut, result, "Got an unexpected delivery")
    }

    static func awaitDelivery(_ semaphore: DispatchSemaphore, expectedPayload: Data,
                              checker: () -> RMQMessage?) {
        awaitDelivery(semaphore, seconds: defaultTimeout,
                      expectedPayload: expectedPayload, checker: checker)
    }

    static func awaitDelivery(_ semaphore: DispatchSemaphore, seconds: Double, expectedPayload: Data,
                              checker: () -> RMQMessage?) {
        let result = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(seconds))
        XCTAssertEqual(.success, result, "Timed out waiting for a delivery")
        let delivered = checker()
        XCTAssertNotNil(delivered)
        XCTAssertEqual(expectedPayload, delivered!.body)
    }

    static func pollUntilTransportDisconnected(_ conn: RMQConnection) -> Bool {
        return TestHelper.pollUntil(defaultTimeout) {
            return conn.transport().isDisconnected()
        }
    }

    static func pollUntilDisconnected(_ conn: RMQConnection) -> Bool {
        return TestHelper.pollUntil(defaultTimeout) {
            return conn.isClosed()
        }
    }

    static func pollUntilConnected(_ conn: RMQConnection) -> Bool {
        return TestHelper.pollUntil(defaultTimeout) {
            return conn.isOpen() && conn.hasCompletedHandshake()
        }
    }
}
