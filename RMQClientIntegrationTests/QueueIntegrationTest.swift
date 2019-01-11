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
class QueueIntegrationTest: XCTestCase {
    func testQueueAndConsumerDSLAutomaticAcknowledgementMode() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x  = ch.fanout("objc.tests.fanouts.testQueueAndConsumerDSLAutomaticAcknowledgementMode",
                           options: [])

        let cons = ch.queue("", options: [.exclusive])
            .bind(x)
            .subscribe(withAckMode: [.auto]) { _ in
                // no-op
        }
        XCTAssertTrue(cons.usesAutomaticAckMode())
        XCTAssertFalse(cons.usesManualAckMode())

        x.delete()
        ch.blockingClose()
        conn.blockingClose()
    }

    func testQueueAndConsumerDSLManualAcknowledgementMode() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.testQueueAndConsumerDSLManualAcknowledgementMode",
                          options: [])

        let cons = ch.queue("objc.tests.queueAndConsumerDSLManualAckMode",
                            options: [.exclusive])
            .bind(x)
            .subscribe(withAckMode: [.manual]) { _ in
                // no-op
        }
        XCTAssertFalse(cons.usesAutomaticAckMode())
        XCTAssertTrue(cons.usesManualAckMode())

        x.delete()
        ch.blockingClose()
        conn.blockingClose()
    }

    func testQueueAndConsumerDSLExclusiveConsumerWithAutomaticAcknowledgementMode() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.testQueueAndConsumerDSLExclusiveConsumer", options: [])

        let cons = ch.queue("objc.tests.queueAndConsumerDSLExclusiveConsumerWithAutomaticAckMode",
                            options: [.exclusive])
            .bind(x)
            // no manual acks
            .subscribe([.exclusive, .noAck]) { _ in
                // no-op
        }
        XCTAssertTrue(cons.usesAutomaticAckMode())
        XCTAssertTrue(cons.isExclusive())

        x.delete()
        ch.blockingClose()
        conn.blockingClose()
    }

    func testManualAcknowledgementOfASingleDelivery() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.testManualAcknowledgementOfASingleDelivery",
                          options: [])

        let semaphore = DispatchSemaphore(value: 0)
        var delivered: RMQMessage?

        let cons = ch.queue("", options: [.exclusive])
            .bind(x)
            .subscribe(withAckMode: [.manual]) { message in
                delivered = message
                ch.ack(message.deliveryTag)
                semaphore.signal()
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        x.publish(body)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(8)),
                       "Timed out waiting for a delivery")
        XCTAssertEqual(body, delivered!.body)
        XCTAssertEqual(delivered!.consumerTag, cons.tag)
        XCTAssertEqual(delivered!.deliveryTag, 1)
        XCTAssertFalse(delivered!.isRedelivered)

        x.delete()
        ch.blockingClose()
        conn.blockingClose()
    }

    func testManualAcknowledgementOfMultipleDeliveries() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.testManualAcknowledgementOfMultipleDeliveries",
                          options: [])

        let semaphore = DispatchSemaphore(value: 0)
        let total = 100
        let counter = AtomicInteger(value: 0)

        ch.queue("", options: [.exclusive])
            .bind(x)
            .subscribe(withAckMode: [.manual]) { message in
                if counter.value >= total {
                    ch.ack(message.deliveryTag, options: [.multiple])
                    semaphore.signal()
                } else {
                    _ = counter.incrementAndGet()
                }
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        for _ in (0...total) {
            x.publish(body)
        }

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(8)),
                       "Timed out waiting for acks")

        x.delete()
        ch.blockingClose()
        conn.blockingClose()
    }

    func testNegativeAcknowledgementOfMultipleDeliveries() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let semaphore = DispatchSemaphore(value: 0)
        let total = 100
        let counter = AtomicInteger(value: 0)

        let q = ch.queue("", options: [.exclusive])
        q.subscribe(withAckMode: [.manual]) { message in
            if counter.value >= total {
                ch.nack(message.deliveryTag, options: [.multiple])
                semaphore.signal()
            } else {
                _ = counter.incrementAndGet()
            }
        }

        let body = "msg".data(using: String.Encoding.utf8)!
        for _ in (0...total) {
            ch.defaultExchange().publish(body, routingKey: q.name!)
        }

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(8)),
                       "Timed out waiting for acks")
        ch.blockingClose()
        conn.blockingClose()
    }

    func testNegativeAcknowledgementWithRequeueingRedelivers() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        let semaphore = DispatchSemaphore(value: 0)

        var isRejected = false
        q.subscribe(withAckMode: [.manual]) { message in
            if isRejected {
                semaphore.signal()
            } else {
                ch.reject(message.deliveryTag, options: [.requeue])
                isRejected = true
            }
        }

        ch.defaultExchange().publish("msg".data(using: String.Encoding.utf8), routingKey: q.name)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for a redelivery")
        ch.blockingClose()
        conn.blockingClose()
    }

    func testNegativeAcknowledgementWithRequeueingRedeliversToADifferentConsumer() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        let semaphore = DispatchSemaphore(value: 0)
        let counter = AtomicInteger(value: 0)
        var activeTags: [String] = []
        var delivered: RMQMessage?

        let handler: RMQConsumerDeliveryHandler = { (message: RMQMessage) -> Void in
            if counter.value < 10 {
                activeTags.append(message.consumerTag)
                ch.nack(message.deliveryTag, options: [.requeue])
                _ = counter.incrementAndGet()
            } else {
                delivered = message
                semaphore.signal()
            }
        }

        // 3 competing consumers in manual acknowledgement mode
        let cons1 = q.subscribe(handler: handler)
        let cons2 = q.subscribe(handler: handler)
        let cons3 = q.subscribe(handler: handler)

        ch.defaultExchange().publish("msg".data(using: String.Encoding.utf8), routingKey: q.name)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for N redeliveries")
        XCTAssertTrue(activeTags.contains(cons1.tag))
        XCTAssertTrue(activeTags.contains(cons2.tag))
        XCTAssertTrue(activeTags.contains(cons3.tag))
        XCTAssertTrue(delivered!.isRedelivered)
        ch.blockingClose()
        conn.blockingClose()
    }

    func testQueueDeletion() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        q.delete()
        // TODO: check for qeueue existence with a predicate
        //       we're yet to add
        ch.blockingClose()
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
        ch.blockingClose()
        conn.blockingClose()
    }

    func testQueuePurge() {
        let conn = RMQConnection()
        conn.start()
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        q.purge()
        // TODO: check the number of messages with a helper
        //       we're yet to add
        ch.blockingClose()
        conn.blockingClose()
    }
}
