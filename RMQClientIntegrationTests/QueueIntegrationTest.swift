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

// swiftlint:disable function_body_length
class QueueIntegrationTest: XCTestCase {
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
        for _ in (0...(total + 10)) {
            x.publish(body)
        }

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(8)),
                       "Timed out waiting for acks")

        x.delete()
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

        ch.defaultExchange().publish("msg".data(using: String.Encoding.utf8)!,
                                     routingKey: q.name)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for a redelivery")
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

        ch.defaultExchange().publish("!msg".data(using: String.Encoding.utf8)!,
                                     routingKey: q.name)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for N redeliveries")
        XCTAssertTrue(activeTags.contains(cons1.tag))
        XCTAssertTrue(activeTags.contains(cons2.tag))
        XCTAssertTrue(activeTags.contains(cons3.tag))
        XCTAssertTrue(delivered!.isRedelivered)
        conn.blockingClose()
    }

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

    func testMessageProperties() {
        let conn = RMQConnection()
        conn.start()
        defer { conn.blockingClose() }

        let semaphore = DispatchSemaphore(value: 0)
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])

        var delivered: RMQMessage?

        q.subscribe(withAckMode: [.auto]) { message in
            delivered = message
            semaphore.signal()
        }

        let date = Date.distantFuture
        let coordinates = RMQTable(["latitude": RMQFloat(59.35), "longitude": RMQFloat(18.066667)])

        let headerDict: [String: RMQValue] = [
            "coordinates": coordinates,
            "time": RMQBasicTimestamp(date),
            "participants": RMQShort(11),
            "venue": RMQLongstr("Stockholm"),
            "true_field": RMQBoolean(true),
            "false_field": RMQBoolean(false),
            "nil_field": RMQVoid(),
            "ary_field": RMQArray([
                RMQLongstr("one"),
                RMQFloat(2.0),
                RMQShort(3),
                RMQArray([RMQTable(["abc": RMQShort(123)])])
                ])
        ]
        let headers = RMQBasicHeaders(headerDict as! [String: RMQValue & RMQFieldValue])

        let props: [RMQValue] = [
            RMQBasicAppId("rmqclient.example"),
            RMQBasicPriority(8),
            RMQBasicType("kinda.checkin"),
            headers,
            RMQBasicTimestamp(date),
            RMQBasicReplyTo("a.sender"),
            RMQBasicCorrelationId("r-1"),
            RMQBasicMessageId("m-1")
        ]
        q.publish("a message".data(using: String.Encoding.utf8)!,
                  properties: (props as! [RMQValue & RMQBasicValue]), options: [])

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for message")

        XCTAssertEqual("application/octet-stream", delivered!.contentType())
        XCTAssertEqual(8, delivered!.priority())
        XCTAssertEqual(headerDict, delivered!.headers())
        XCTAssertEqual(date.timeIntervalSinceReferenceDate, delivered!.timestamp().timeIntervalSinceReferenceDate,
                       accuracy: 1)
        XCTAssertEqual("kinda.checkin", delivered!.messageType())
        XCTAssertEqual("a.sender", delivered!.replyTo())
        XCTAssertEqual("r-1", delivered!.correlationID())
        XCTAssertEqual("m-1", delivered!.messageID())
        XCTAssertEqual("rmqclient.example", delivered!.appID())

        let consumerTag = delivered!.consumerTag
        XCTAssertTrue(consumerTag!.starts(with: "rmq-objc-client.gen-"))
        XCTAssertEqual(1, delivered!.deliveryTag)
        XCTAssertEqual(q.name, delivered!.routingKey)
        XCTAssertEqual("", delivered!.exchangeName)

        let missingDefaultsCount = 2
        XCTAssertEqual(props.count + missingDefaultsCount, delivered!.properties.count)
    }

    func testMultipleConsumersOnSameChannel() {
        let conn = RMQConnection()
        conn.start()
        defer { conn.blockingClose() }

        var set1 = Set<NSNumber>()
        var set2 = Set<NSNumber>()
        var set3 = Set<NSNumber>()

        let messageCount = 4000
        let semaphore = DispatchSemaphore(value: 0)
        let consumingChannel = conn.createChannel()
        let consumingQueue = consumingChannel.queue("", options: [.autoDelete, .exclusive])

        consumingQueue.subscribe(handler: { message in
            set1.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        consumingQueue.subscribe(handler: { message in
            set2.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        consumingQueue.subscribe(handler: { message in
            set3.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        usleep(1500000) // 1.5 seconds

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(consumingQueue.name, options: [.autoDelete, .exclusive])

        for _ in 1...messageCount {
            producingQueue.publish("h!ello".data(using: String.Encoding.utf8)!)
        }

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(50)),
                       "Timed out waiting for messages to arrive on single channel")

        let emptyCount = [set1, set2, set3].reduce(0) { (acc, set) -> Int in
            acc + (set.isEmpty ? 1 : 0)
        }

        XCTAssertLessThan(emptyCount, 2)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...messageCount).map { NSNumber(value: $0 as Int) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))
    }

    func testConcurrentDeliveryOnDifferentChannels() {
        let counter = AtomicInteger(value: 0)
        let semaphore = DispatchSemaphore(value: 0)
        let delegate = RMQConnectionDelegateLogger()
        let channelCount = 500
        let messageCount: Int32 = 500
        let conn = RMQConnection(uri: IntegrationHelper.defaultEndpoint,
                                 tlsOptions: RMQTLSOptions.fromURI(IntegrationHelper.defaultEndpoint),
                                 delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue("some-queue", options: [.autoDelete, .exclusive])

        for _ in 1...channelCount {
            let ch = conn.createChannel()
            let q = ch.queue(producingQueue.name, options: [.autoDelete, .exclusive])
            q.subscribe(handler: { _ in
                if counter.incrementAndGet() >= messageCount {
                    semaphore.signal()
                }
            })
        }

        for _ in 1...messageCount {
            producingQueue.publish("hello".data(using: String.Encoding.utf8)!)
        }

        XCTAssertEqual(
            .success,
            semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(15)),
            "Timed out waiting for messages to arrive on different channels"
        )
    }
}
