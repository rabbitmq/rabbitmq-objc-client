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

// see https://github.com/rabbitmq/rabbitmq-objc-client/blob/master/CONTRIBUTING.md
// to set up your system for running integration tests
class ConnectionLifecycleIntegrationTest: XCTestCase {
    let endpoint = IntegrationHelper.defaultEndpoint

    func testConnectingWithAllDefaults() {
        let semaphore = DispatchSemaphore(value: 0)
        let conn = RMQConnection()
        conn.start {
            semaphore.signal()
        }

        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(semaphore),
            "Timed out waiting for connection and handshake to complete")

        XCTAssert(conn.isOpen())
        conn.blockingClose()
    }

    func testConnectingWithAURI() {
        let delegate = RMQConnectionDelegateLogger()
        let conn = RMQConnection(uri: IntegrationHelper.defaultEndpoint,
                                 delegate: delegate)
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        XCTAssert(conn.isOpen())
        conn.blockingClose()
    }

    func testConnectingWithAURIThatHasEncodedSlashesInPath() {
        let delegate = RMQConnectionDelegateLogger()
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost:5672/vhost%2Fwith%2Fa%2Ffew%2Fslashes",
                                 delegate: delegate)
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        XCTAssert(conn.isOpen())
        conn.blockingClose()
    }

    func testUserInitiatedClosure() {
        let conn = RMQConnection()
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        XCTAssertTrue((conn.transport().isConnected()))
        XCTAssertTrue(conn.isOpen())
        XCTAssertTrue(conn.hasCompletedHandshake())
        XCTAssertFalse(conn.isClosed())

        conn.blockingClose()

        XCTAssertTrue(IntegrationHelper.pollUntilDisconnected(conn))
        XCTAssertTrue(IntegrationHelper.pollUntilTransportDisconnected(conn))
        XCTAssertFalse(conn.isOpen())
        XCTAssertTrue(conn.isClosed())
    }

    func testServerProperties() {
        let conn = RMQConnection()
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        let props = conn.serverProperties.dictionaryValue
        XCTAssertNotNil(props["product"] ?? nil)
        XCTAssertNotNil(props["version"] ?? nil)
        XCTAssertNotNil(props["capabilities"] ?? nil)

        conn.blockingClose()
    }

    func testUserProvidedConnectionName() {
        let conn = RMQConnection(uri: IntegrationHelper.defaultEndpoint,
                                 userProvidedConnectionName: "testUserProvidedConnectionName.1",
                                 delegate: RMQConnectionDelegateLogger())
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        XCTAssert(conn.isOpen())
        conn.blockingClose()
    }
}
