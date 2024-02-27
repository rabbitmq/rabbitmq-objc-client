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

class QueueIntegrationTest: XCTestCase {

    //
    // queue.unbind
    //

    func testUnbinding() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x  = ch.topic("objc.tests.topic3", options: [])

        let semaphore = DispatchSemaphore(value: 0)
        let rk = "cities.*"

        ch.queue("", options: [.exclusive])
            .bind(x, routingKey: rk)
            .unbind(x, routingKey: rk)
            .subscribe(withAckMode: [.auto]) { _ in semaphore.signal() }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body, routingKey: "cities.bogotá")
        x.publish(body, routingKey: "cities.melbourne")
        x.publish(body, routingKey: "cities.manama")

        IntegrationHelper.awaitNoCompletion(semaphore)

        x.delete()
        conn.blockingClose()
    }

    //
    // queue.delete
    //

    func testQueueDeletion() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        q.delete()
        // TODO: check for qeueue existence with a predicate
        //       we're yet to add
        conn.blockingClose()
    }

    func testQueueDeletionWithOptions() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        q.delete([.ifEmpty])
        // queue deletion is idempotent
        q.delete([.ifUnused])
        // TODO: check for qeueue existence with a predicate
        //       we're yet to add
        conn.blockingClose()
    }

    //
    // queue.purge
    //

    func testQueuePurge() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        q.purge()
        // TODO: check the number of messages with a helper
        //       we're yet to add
        conn.blockingClose()
    }
}
