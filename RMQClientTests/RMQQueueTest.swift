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

class RMQQueueTest: XCTestCase {
    let body = "a message".data(using: String.Encoding.utf8)!
    func testPublishSendsBasicPublishToChannel() {
        let channel = ChannelSpy(channelNumber: 42)
        channel.publishReturn = 123
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        let retval = queue.publish(body)

        XCTAssertEqual(123, retval)
        XCTAssertEqual(body, channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithPersistence() {
        let channel = ChannelSpy(channelNumber: 42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        queue.publish(body, persistent: true)

        XCTAssertEqual(body, channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([RMQBasicDeliveryMode(2)], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], channel.lastReceivedBasicPublishOptions)
    }

    func testPublishWithProperties() {
        let channel = ChannelSpy(channelNumber: 42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")
        let timestamp = Date()

        let properties: [RMQValue] = [
            RMQBasicAppId("some.app"),
            RMQBasicContentEncoding("utf-999"),
            RMQBasicContentType("application/json"),
            RMQBasicCorrelationId("reply2meplz"),
            RMQBasicExpiration("123"),
            RMQBasicMessageId("havdizreplym8"),
            RMQBasicDeliveryMode(2),
            RMQBasicPriority(8),
            RMQBasicReplyTo("some.person"),
            RMQBasicTimestamp(timestamp),
            RMQBasicType("some.type"),
            RMQBasicUserId("my.login"),
            BasicPropertyFixtures.exhaustiveHeaders()
        ]

        queue.publish("{\"a\": \"message\"}".data(using: String.Encoding.utf8)!,
                      properties: (properties as! [RMQValue & RMQBasicValue]),
                      options: [.mandatory])

        XCTAssertEqual("{\"a\": \"message\"}".data(using: String.Encoding.utf8),
                       channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([.mandatory], channel.lastReceivedBasicPublishOptions)
        XCTAssertEqual(properties, channel.lastReceivedBasicPublishProperties!)
    }

    func testPublishWithOptions() {
        let channel = ChannelSpy(channelNumber: 42)
        let queue = QueueHelper.makeQueue(channel, name: "some.queue")

        queue.publish(body, persistent: false, options: [.mandatory])

        XCTAssertEqual(body, channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], channel.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([.mandatory], channel.lastReceivedBasicPublishOptions)
    }

    func testPopDelegatesToChannelBasicGet() {
        let stubbedMessage = RMQMessage(body: body, consumerTag: "", deliveryTag: 123, redelivered: false,
                                        exchangeName: "", routingKey: "", properties: [])
        let channel = ChannelSpy(channelNumber: 42)
        let queue = QueueHelper.makeQueue(channel, name: "great.queue")

        var receivedMessage: RMQMessage?
        queue.pop { m in
            receivedMessage = m
        }

        XCTAssertEqual("great.queue", channel.lastReceivedBasicGetQueue)
        XCTAssertEqual([], channel.lastReceivedBasicGetOptions)

        channel.lastReceivedBasicGetCompletionHandler!(stubbedMessage!)
        XCTAssertEqual(stubbedMessage, receivedMessage)
    }

    func testSubscribeSendsABasicConsumeToChannelWithAutoAck() {
        let channel = ChannelSpy(channelNumber: 123)
        let queue = QueueHelper.makeQueue(channel, name: "default options")

        var handlerCalled = false
        queue.subscribe({ _ in
            handlerCalled = true
        })

        let message = RMQMessage(body: "I have default options!".data(using: String.Encoding.utf8),
                                 consumerTag: "", deliveryTag: 123, redelivered: false, exchangeName: "",
                                 routingKey: "", properties: [])
        channel.lastReceivedBasicConsumeBlock!(message!)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.noAck], channel.lastReceivedBasicConsumeOptions)
    }

    func testSubscribeWithOptionsSendsOptionsToChannel() {
        let channel = ChannelSpy(channelNumber: 123)
        let queue = QueueHelper.makeQueue(channel, name: "custom options")

        var handlerCalled = false
        queue.subscribe([.exclusive], handler: { _ in
            handlerCalled = true
        })

        let message = RMQMessage(body: "I have custom options!".data(using: String.Encoding.utf8),
                                 consumerTag: "", deliveryTag: 123, redelivered: false, exchangeName: "",
                                 routingKey: "", properties: [])
        channel.lastReceivedBasicConsumeBlock!(message!)

        XCTAssert(handlerCalled)
        XCTAssertEqual([.exclusive], channel.lastReceivedBasicConsumeOptions)
    }

    func testCancellingASubscriptionSendsBasicCancelToChannel() {
        let channel = ChannelSpy(channelNumber: 123)
        let queue = QueueHelper.makeQueue(channel, name: "cancelling")

        let consumer = queue.subscribe({ _ in })
        XCTAssertNotNil(consumer.tag)

        consumer.cancel()
        XCTAssertEqual(consumer.tag, channel.lastReceivedBasicCancelConsumerTag)
    }

    func testBindCallsBindOnChannel() {
        let channel = ChannelSpy(channelNumber: 123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)!
        let queue = QueueHelper.makeQueue(channel, name: "bindy")

        queue.bind(ex, routingKey: "foo")

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueBindRoutingKey)
    }

    func testBindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(channelNumber: 123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)!
        let queue = QueueHelper.makeQueue(channel, name: "bindy")

        queue.bind(ex)

        XCTAssertEqual("bindy", channel.lastReceivedQueueBindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueBindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueBindRoutingKey)
    }

    func testUnbindCallsUnbindOnChannel() {
        let channel = ChannelSpy(channelNumber: 123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)!
        let queue = QueueHelper.makeQueue(channel, name: "unbindy")

        queue.unbind(ex, routingKey: "foo")

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("foo", channel.lastReceivedQueueUnbindRoutingKey)
    }

    func testUnbindWithoutRoutingKeySendsEmptyStringRoutingKey() {
        let channel = ChannelSpy(channelNumber: 123)
        let ex = RMQExchange(name: "my-exchange", type: "direct", options: [], channel: channel)!
        let queue = QueueHelper.makeQueue(channel, name: "unbindy")

        queue.unbind(ex)

        XCTAssertEqual("unbindy", channel.lastReceivedQueueUnbindQueueName)
        XCTAssertEqual("my-exchange", channel.lastReceivedQueueUnbindExchange)
        XCTAssertEqual("", channel.lastReceivedQueueUnbindRoutingKey)
    }

    func testDeleteCallsDeleteOnChannel() {
        let channel = ChannelSpy(channelNumber: 123)
        let queue = QueueHelper.makeQueue(channel, name: "deletable")

        queue.delete()
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([], channel.lastReceivedQueueDeleteOptions)

        queue.delete([.ifEmpty])
        XCTAssertEqual("deletable", channel.lastReceivedQueueDeleteQueueName)
        XCTAssertEqual([.ifEmpty], channel.lastReceivedQueueDeleteOptions)
    }

}
