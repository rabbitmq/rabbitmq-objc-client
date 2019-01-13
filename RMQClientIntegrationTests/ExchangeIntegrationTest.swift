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

// see https://github.com/rabbitmq/rabbitmq-objc-client/blob/master/CONTRIBUTING.md
// to set up your system for running integration tests
class ExchangeIntegrationTest: XCTestCase {
    func testDefaultExchangeAndImplicitBindingUsingRMQQueueShortcut() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.exclusive])

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        q.subscribe(withAckMode: [.auto]) { message in
            delivered = message
            semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        q.publish(body)

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })

        conn.blockingClose()
    }

    func testDefaultExchangeAndImplicitBinding() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q: RMQQueue = ch.queue("", options: [.exclusive])

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        q.subscribe(withAckMode: [.auto]) { message in
            delivered = message
            semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        ch.defaultExchange().publish(body, routingKey: q.name!)

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })
        conn.blockingClose()
    }

    func testFanoutExchange() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanout", options: [])

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        ch.queue("", options: [.exclusive])
            .bind(x)
            .subscribe(withAckMode: [.auto]) { message in
                delivered = message
                semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body)

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })

        x.delete()
        conn.blockingClose()
    }

    func testDirectExchangeWithMatchingBindings() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.direct("objc.tests.direct", options: [])

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        let rk = "example-rk-value"
        let q  = ch.queue("", options: [.exclusive])
        q.bind(x, routingKey: rk).subscribe(withAckMode: [.auto]) { message in
                delivered = message
                semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body, routingKey: rk)

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })

        x.delete()
        conn.blockingClose()
    }

    func testDirectExchangeWithoutAnyBindings() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.direct("objc.tests.direct-without-bindings", options: [])

        let semaphore = DispatchSemaphore(value: 0)

        let rk = "expected-rk-value"
        let q  = ch.queue("", options: [.exclusive])
        q.bind(x, routingKey: rk).subscribe(withAckMode: [.auto]) { message in
            print(message)
            semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body, routingKey: "won't route ¯\\_(ツ)_/¯")

        IntegrationHelper.awaitNoCompletion(semaphore)

        x.delete()
        conn.blockingClose()
    }

    func testTopicExchangeWithMatchingBindings() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.topic("objc.tests.topic", options: [])

        let n = AtomicInteger(value: 0)

        ch.queue("", options: [.exclusive])
            .bind(x, routingKey: "cities.*")
            .subscribe(withAckMode: [.auto]) { _ in _ = n.incrementAndGet() }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body, routingKey: "cities.singapore")
        x.publish(body, routingKey: "cities.newyorkcity")
        x.publish(body, routingKey: "cities.moscow")

        XCTAssertTrue(TestHelper.pollUntil { n.value >= 3 })

        x.delete()
        conn.blockingClose()
    }

    func testTopicExchangeWithNonMatchingBindings() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x  = ch.topic("objc.tests.topic2", options: [])

        let semaphore = DispatchSemaphore(value: 0)

        ch.queue("", options: [.exclusive])
            .bind(x, routingKey: "cities.*")
            .subscribe(withAckMode: [.auto]) { _ in semaphore.signal() }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body, routingKey: "locations.capetown")
        x.publish(body, routingKey: "locations.delhi")
        x.publish(body, routingKey: "locations.lisbon")

        IntegrationHelper.awaitNoCompletion(semaphore)

        x.delete()
        conn.blockingClose()
    }

    func testExchangeToExchangeBindingWithFanouts() {
        let conn = RMQConnection()
        conn.start()

        let ch = conn.createChannel()

        let x1 = ch.fanout("objc.tests.fanout1", options: [])
        let x2 = ch.fanout("objc.tests.fanout2", options: [])

        // x1 is the source
        x2.bind(x1)

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        ch.queue("", options: [.exclusive])
            .bind(x2)
            .subscribeAutoAcks { message in
                delivered = message
                semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x1.publish(body)

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })

        x1.delete()
        x2.delete()

        conn.blockingClose()
    }

    func testExchangeToExchangeBindingWithTopics() {
        let conn = RMQConnection()
        conn.start()

        let ch = conn.createChannel()

        let x1 = ch.topic("objc.tests.topic1", options: [])
        let x2 = ch.topic("objc.tests.topic2", options: [])

        // x1 is the source
        x2.bind(x1, routingKey: "cities.*")

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        ch.queue("", options: [.exclusive])
            .bind(x2, routingKey: "cities.*")
            .subscribeAutoAcks { message in
                delivered = message
                semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x1.publish(body, routingKey: "cities.lima")

        IntegrationHelper.awaitDelivery(semaphore,
                                        expectedPayload: body, checker: { return delivered })

        x1.delete()
        x2.delete()

        conn.blockingClose()
    }

    //
    // exchange.unbind
    //

    func testExchangeToExchangeUnbinding() {
        let conn = RMQConnection()
        conn.start()

        let ch = conn.createChannel()

        let x1 = ch.topic("objc.tests.topic1", options: [])
        let x2 = ch.topic("objc.tests.topic2", options: [])

        let rk = "cities.*"

        // x1 is the source
        x2.bind(x1, routingKey: rk)
        x2.unbind(x1, routingKey: rk)

        let semaphore = DispatchSemaphore(value: 0)

        ch.queue("", options: [.exclusive])
            .bind(x2, routingKey: "cities.*")
            .subscribeAutoAcks { _ in semaphore.signal() }

        let body = "msg".data(using: String.Encoding.utf8)!
        x1.publish(body, routingKey: "cities.lima")

        IntegrationHelper.awaitNoCompletion(semaphore)

        x1.delete()
        x2.delete()

        conn.blockingClose()
    }

    //
    // exchange.delete
    //

    func testDeletingAnExchangeIsIdempotent() {
        let conn = RMQConnection()
        conn.start()
        _ = IntegrationHelper.pollUntilConnected(conn)
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanout", options: [])

        ch.queue("", options: [.exclusive]).bind(x)
        x.delete()
        for _ in (0...20) {
            x.delete()
        }
        conn.blockingClose()
    }
}
