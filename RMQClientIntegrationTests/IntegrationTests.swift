// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 1.1 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2016 Pivotal Software, Inc.
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

// see https://github.com/rabbitmq/rabbitmq-objc-client#running-tests
// to set up your system for running these tests
class IntegrationTests: XCTestCase {
    let amqpLocalhost = "amqp://guest:guest@127.0.0.1"

    func testPop() {
        let frameMaxRequiringTwoFrames = 4096
        var messageContent = ""
        for _ in 1...(frameMaxRequiringTwoFrames - RMQEmptyFrameSize) {
            messageContent += "a"
        }
        messageContent += "bb"

        let conn = RMQConnection(
            uri: amqpLocalhost,
            tlsOptions: RMQTLSOptions.fromURI(amqpLocalhost),
            channelMax: RMQChannelLimit,
            frameMax: frameMaxRequiringTwoFrames,
            heartbeat: 0,
            syncTimeout: 10,
            delegate: nil,
            delegateQueue: dispatch_get_main_queue(),
            recoverAfter: 0,
            recoveryAttempts: 0,
            recoverFromConnectionClose: false
        )
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let src = ch.fanout("src", options: [.AutoDelete])
        let dst = ch.fanout("dest", options: [.AutoDelete])
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        dst.bind(src)
        q.bind(dst)

        let body = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!

        src.publish(body)

        let semaphore = dispatch_semaphore_create(0)
        let expected = RMQMessage(
            body: body,
            consumerTag: "",
            deliveryTag: 1,
            redelivered: false,
            exchangeName: src.name,
            routingKey: "",
            properties: RMQBasicProperties.defaultProperties()
        )
        var actual: RMQMessage?
        q.pop { m in
            actual = m
            dispatch_semaphore_signal(semaphore)
        }

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(2)),
                       "Timed out waiting for pop block to execute")
        XCTAssertEqual(expected, actual)
    }

    func testSubscribeWithClientCertificateAuthentication() {
        let delegate = RMQConnectionDelegateLogger()
        let noisyHeartbeats = 1
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: CertificateFixtures.guestBunniesP12(),
            pkcs12Password: "bunnies"
        )
        let conn = RMQConnection(uri: "amqps://localhost",
                                 tlsOptions: tlsOptions,
                                 channelMax: RMQChannelLimit,
                                 frameMax: RMQFrameMax,
                                 heartbeat: noisyHeartbeats,
                                 syncTimeout: 10,
                                 delegate: delegate,
                                 delegateQueue: dispatch_get_main_queue(),
                                 recoverAfter: 0,
                                 recoveryAttempts: 0,
                                 recoverFromConnectionClose: false)
        conn.start()
        defer { conn.blockingClose() }

        let semaphore = dispatch_semaphore_create(0)
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        var delivered: RMQMessage?

        q.subscribe([.NoOptions]) { message in
            delivered = message
            ch.ack(message.deliveryTag)
            dispatch_semaphore_signal(semaphore)
        }

        let body = "my message".dataUsingEncoding(NSUTF8StringEncoding)!

        q.publish(body)

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for message")

        XCTAssertEqual(1, delivered!.deliveryTag)
        XCTAssertEqual(body, delivered!.body)
    }

    func testMessageProperties() {
        let conn = RMQConnection()
        conn.start()
        defer { conn.blockingClose() }

        let semaphore = dispatch_semaphore_create(0)
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        var delivered: RMQMessage?

        q.subscribe([.NoAck]) { message in
            delivered = message
            dispatch_semaphore_signal(semaphore)
        }

        let date = NSDate.distantFuture()
        let coordinates = RMQTable(["latitude": RMQFloat(59.35), "longitude": RMQFloat(18.066667)])

        let headerDict: [String : RMQValue] = [
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
                ]),
            ]
        let headers = RMQBasicHeaders(headerDict)

        let props: [RMQValue] = [
            RMQBasicAppId("rmqclient.example"),
            RMQBasicPriority(8),
            RMQBasicType("kinda.checkin"),
            headers,
            RMQBasicTimestamp(date),
            RMQBasicReplyTo("a.sender"),
            RMQBasicCorrelationId("r-1"),
            RMQBasicMessageId("m-1"),
            ]
        q.publish("a message".dataUsingEncoding(NSUTF8StringEncoding), properties: props, options: [])

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for message")

        XCTAssertEqual("application/octet-stream",          delivered!.contentType())
        XCTAssertEqual(8,                                   delivered!.priority())
        XCTAssertEqual(headerDict,                          delivered!.headers())
        XCTAssertEqualWithAccuracy(date.timeIntervalSinceReferenceDate,
                                                            delivered!.timestamp().timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual("kinda.checkin",                     delivered!.messageType())
        XCTAssertEqual("a.sender",                          delivered!.replyTo())
        XCTAssertEqual("r-1",                               delivered!.correlationID())
        XCTAssertEqual("m-1",                               delivered!.messageID())
        XCTAssertEqual("rmqclient.example",                 delivered!.appID())

        let consumerTag = delivered!.consumerTag
        XCTAssertEqual("rmq-objc-client.gen-",              consumerTag.substringToIndex(consumerTag.startIndex.advancedBy(20)))
        XCTAssertEqual(1,                                   delivered!.deliveryTag)
        XCTAssertEqual(q.name,                              delivered!.routingKey)
        XCTAssertEqual("",                                  delivered!.exchangeName)

        let missingDefaultsCount = 2
        XCTAssertEqual(props.count + missingDefaultsCount,  delivered!.properties.count)
    }

    func testRejectAndRequeueCausesSecondDelivery() {
        let conn = RMQConnection(uri: amqpLocalhost, delegate: nil, recoverAfter: 0)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0)

        var isRejected = false

        q.subscribe([.NoOptions]) { message in
            if isRejected {
                dispatch_semaphore_signal(semaphore)
            } else {
                isRejected = true
                ch.reject(message.deliveryTag, options: [.Requeue])
            }
        }

        ch.defaultExchange().publish("my message".dataUsingEncoding(NSUTF8StringEncoding), routingKey: q.name)

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for second delivery")
    }

    func testMultipleConsumersOnSameChannel() {
        let conn = RMQConnection(uri: amqpLocalhost, delegate: nil, recoverAfter: 0)
        conn.start()
        defer { conn.blockingClose() }

        var set1 = Set<NSNumber>()
        var set2 = Set<NSNumber>()
        var set3 = Set<NSNumber>()

        let messageCount = 4000
        let consumingChannel = conn.createChannel()
        let consumingQueue = consumingChannel.queue("", options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0);

        consumingQueue.subscribe { message in
            set1.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { message in
            set2.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { message in
            set3.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        usleep(1500000) // 1.5 seconds

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(consumingQueue.name, options: [.AutoDelete, .Exclusive])

        for _ in 1...messageCount {
            producingQueue.publish("hello".dataUsingEncoding(NSUTF8StringEncoding))
        }

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(50)),
                       "Timed out waiting for messages to arrive on single channel")

        let emptyCount = [set1, set2, set3].reduce(0) { (acc, set) -> Int in
            acc + (set.isEmpty ? 1 : 0)
        }

        XCTAssertLessThan(emptyCount, 2)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...messageCount).map { NSNumber(integer: $0) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))
    }

    func testConcurrentDeliveryOnDifferentChannels() {
        var counter: Int32 = 0
        let semaphore = dispatch_semaphore_create(0)
        let delegate = RMQConnectionDelegateLogger()
        let channelCount = 600
        let messageCount: Int32 = 600
        let conn = RMQConnection(uri: amqpLocalhost,
                                 tlsOptions: RMQTLSOptions.fromURI(amqpLocalhost),
                                 channelMax: channelCount + 1, frameMax: RMQFrameMax, heartbeat: 100, syncTimeout: 60,
                                 delegate: delegate, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                 recoverAfter: 0, recoveryAttempts: 0, recoverFromConnectionClose: false)
        conn.start()
        defer { conn.blockingClose() }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue("some-queue", options: [.AutoDelete, .Exclusive])

        for _ in 1...channelCount {
            let ch = conn.createChannel()
            let q = ch.queue(producingQueue.name, options: [.AutoDelete, .Exclusive])
            q.subscribe { message in
                OSAtomicIncrement32(&counter)
                if counter == messageCount {
                    dispatch_semaphore_signal(semaphore)
                }
            }
        }

        for _ in 1...messageCount {
            producingQueue.publish("hello".dataUsingEncoding(NSUTF8StringEncoding))
        }

        XCTAssertEqual(
            0,
            dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(30)),
            "Timed out waiting for messages to arrive on different channels"
        )
    }

    func testClientChannelCloseCausesFutureOperationsToFail() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(uri: amqpLocalhost, delegate: delegate, recoverAfter: 0)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()

        ch.close()

        XCTAssert(
            TestHelper.pollUntil(30) {
                ch.basicQos(1, global: false)
                return delegate.lastChannelError?.code == RMQError.ChannelClosed.rawValue
            }
        )
    }

    func testServerChannelCloseCausesFutureOperationsToFail() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(uri: amqpLocalhost, delegate: delegate, recoverAfter: 0)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()

        causeServerChannelClose(ch)

        XCTAssert(
            TestHelper.pollUntil(30) {
                ch.basicQos(1, global: false)
                return delegate.lastChannelError?.code == RMQError.ChannelClosed.rawValue
            }
        )
    }

    private func causeServerChannelClose(ch: RMQChannel) {
        ch.basicPublish("".dataUsingEncoding(NSUTF8StringEncoding)!, routingKey: "a route that can't be found", exchange: "a non-existent exchange", properties: [], options: [])
    }
}
