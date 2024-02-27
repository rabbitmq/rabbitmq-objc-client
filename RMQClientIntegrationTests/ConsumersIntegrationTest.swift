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
// swiftlint:disable function_body_length
class ConsumersIntegrationTest: XCTestCase {

    //
    // Consumers
    //

    func testQueueAndConsumerDSLManualAcknowledgementMode() {
        let testName = "testQueueAndConsumerDSLManualAcknowledgementMode"
        let conn = IntegrationHelper.createNamedConnection(testName)
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.\(testName)",
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
        let testName = "testQueueAndConsumerDSLExclusiveConsumerWithAutomaticAcknowledgementMode"
        let conn = IntegrationHelper.createNamedConnection(testName)
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("objc.tests.fanouts.\(testName)", options: [])

        let cons = ch.queue("objc.tests.queues.\(testName)",
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

    func testNegativeAcknowledgementOfMultipleDeliveries() {
        let testName = "testNegativeAcknowledgementOfMultipleDeliveries"
        let conn = IntegrationHelper.createNamedConnection(testName)
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
            ch.defaultExchange().publish(body, routingKey: q.name)
        }

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(8)),
                       "Timed out waiting for acks")
        conn.blockingClose()
    }

    func testNegativeAcknowledgementWithRequeueingRedelivers() {
        let testName = "testNegativeAcknowledgementWithRequeueingRedelivers"
        let conn = IntegrationHelper.createNamedConnection(testName)
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
        let testName = "testNegativeAcknowledgementWithRequeueingRedeliversToADifferentConsumer"
        let conn = IntegrationHelper.createNamedConnection(testName)
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

        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(semaphore))
        XCTAssertTrue(activeTags.contains(cons1.tag))
        XCTAssertTrue(activeTags.contains(cons2.tag))
        XCTAssertTrue(activeTags.contains(cons3.tag))
        XCTAssertTrue(delivered!.isRedelivered)
        conn.blockingClose()
    }

    func testManualAcknowledgementOfMultipleDeliveries() {
        let testName = "testManualAcknowledgementOfMultipleDeliveries"
        let conn = IntegrationHelper.createNamedConnection(testName)
        conn.start()
        let ch = conn.createChannel()
        let x = ch.fanout("amq.fanout", options: [.durable])

        let semaphore = DispatchSemaphore(value: 0)
        let total = 20
        let counter = AtomicInteger(value: 0)

        ch.queue("objc.tests.fanouts.multiack \(Int.random(in: (0...10)))", options: [.exclusive])
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

    //
    // Assorted tests
    //

    func testMessageProperties() {
        let testName = "testMessageProperties"
        let conn = IntegrationHelper.createNamedConnection(testName)
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
        let body = "a message".data(using: String.Encoding.utf8)!
        q.publish(body, properties: (props as! [RMQValue & RMQBasicValue]), options: [])

        IntegrationHelper.awaitDelivery(semaphore, expectedPayload: body, checker: { delivered })

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

    //
    // basic.get
    //

    func testBasicGetWithResults() {
        let conn = RMQConnection()
        conn.start()

        let deliverySemaphore = DispatchSemaphore(value: 0)
        let ch = conn.createChannel()
        ch.confirmSelect()

        let x = ch.fanout("amq.fanout", options: [.durable])
        let q = ch.queue("objc.tests.queues.basic-get \(Int.random(in: 200...1000))",
            options: [.exclusive]).bind(x)

        usleep(500000) // 0.5 seconds

        let confirmsSemaphore = DispatchSemaphore(value: 0)
        let body = "!msg".data(using: String.Encoding.utf8)!
        x.publish(body)

        ch.afterConfirmed { (_, _) in
            confirmsSemaphore.signal()
        }

        var delivered: RMQMessage?
        q.pop { (message) in
            delivered = message
            deliverySemaphore.signal()
        }

        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(confirmsSemaphore))
        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(deliverySemaphore, timeout: 10))
        XCTAssertEqual(delivered?.body, body)

        conn.blockingClose()
    }

    //
    // Misc
    //

    func testConcurrentDeliveryOnDifferentChannels() {
        let counter  = AtomicInteger(value: 0)
        let delegate = RMQConnectionDelegateLogger()
        let channelCount = 8
        let messageCount = channelCount * 50
        let conn = RMQConnection(uri: IntegrationHelper.defaultEndpoint,
                                 delegate: delegate)
        conn.start()
        XCTAssertTrue(IntegrationHelper.pollUntilConnected(conn))

        let ch1   = conn.createChannel()
        ch1.confirmSelect()
        let confirmsSemaphore = DispatchSemaphore(value: 0)

        let qName = "objc.tests.consumers.compting-consumers.1"
        let deliverySemaphore = DispatchSemaphore(value: 0)

        for _ in 1...channelCount {
            let ch = conn.createChannel()
            let q = ch.queue(qName, options: [.exclusive])
            q.subscribe(withAckMode: [.auto]) { _ in
                if counter.incrementAndGet() >= messageCount {
                    print("Consumed all \(messageCount) messages...")
                    deliverySemaphore.signal()
                }
            }
        }

        for _ in 1...messageCount {
            ch1.defaultExchange()
                .publish("hello".data(using: String.Encoding.utf8)!, routingKey: qName)
        }
        ch1.afterConfirmed { (_, nacks) in
            if !nacks.isEmpty {
                print("Nacks: \(nacks)")
            }
            confirmsSemaphore.signal()
        }

        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(confirmsSemaphore, timeout: 10))
        XCTAssertEqual(.success, IntegrationHelper.awaitCompletion(deliverySemaphore, timeout: 10))

        conn.blockingClose()
    }

    func testMultipleConsumersOnSameChannel() {
        let conn = RMQConnection()
        conn.start()

        var set1 = Set<NSNumber>()
        var set2 = Set<NSNumber>()
        var set3 = Set<NSNumber>()

        let messageCount = 300
        let semaphore    = DispatchSemaphore(value: 0)
        let ch = conn.createChannel()
        let q  = ch.queue("objc.tests.consumers.competing-consumers.2", options: [.exclusive])

        q.subscribe(handler: { message in
            set1.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        q.subscribe(handler: { message in
            set2.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        q.subscribe(handler: { message in
            set3.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                semaphore.signal()
            }
        })

        usleep(1500000) // 1.5 seconds

        let ch1 = conn.createChannel()
        let x   = ch1.fanout("amq.fanout", options: [.durable])
        q.bind(x)

        for _ in 1...messageCount {
            x.publish("h!ello".data(using: String.Encoding.utf8)!)
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

        conn.blockingClose()
    }
}
