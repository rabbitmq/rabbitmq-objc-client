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

class RMQExchangeTest: XCTestCase {

    let body = "foo".data(using: String.Encoding.utf8)!

    func testPublishCallsPublishOnChannel() {
        let ch = ChannelSpy(channelNumber: 1)
        ch.publishReturn = 123
        let ex = RMQExchange(name: "", type: "direct", options: [], channel: ch)
        let retval = ex?.publish(body, routingKey: "my.q")

        XCTAssertEqual(123, retval)
        XCTAssertEqual(body, ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], ch.lastReceivedBasicPublishOptions)
    }

    func testPublishWithoutRoutingKeyUsesEmptyString() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex = RMQExchange(name: "", type: "direct", options: [], channel: ch)
        _ = ex?.publish(body)

        XCTAssertEqual("", ch.lastReceivedBasicPublishRoutingKey)
    }

    func testPublishWithPersistence() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex = RMQExchange(name: "some-ex", type: "direct", options: [], channel: ch)
        _ = ex?.publish(body, routingKey: "my.q", persistent: true)

        XCTAssertEqual(body, ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual([RMQBasicDeliveryMode(2)], ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], ch.lastReceivedBasicPublishOptions)
    }

    func testPublishWithProperties() {
        let channel = ChannelSpy(channelNumber: 42)
        let ex = RMQExchange(name: "some-ex", type: "direct", options: [], channel: channel)
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

        _ = ex?.publish("{\"a\": \"message\"}".data(using: String.Encoding.utf8)!,
                        routingKey: "some.queue",
                        properties: (properties as! [RMQValue & RMQBasicValue]),
                        options: [.mandatory])

        XCTAssertEqual("{\"a\": \"message\"}".data(using: String.Encoding.utf8),
                       channel.lastReceivedBasicPublishMessage)
        XCTAssertEqual("some.queue", channel.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", channel.lastReceivedBasicPublishExchange)
        XCTAssertEqual([.mandatory], channel.lastReceivedBasicPublishOptions)
        XCTAssertEqual(properties, channel.lastReceivedBasicPublishProperties!)
    }

    func testPublishWithOptions() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex = RMQExchange(name: "some-ex", type: "direct", options: [], channel: ch)
        _ = ex?.publish(body, routingKey: "my.q", persistent: false, options: [.mandatory])

        XCTAssertEqual(body, ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual([], ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([.mandatory], ch.lastReceivedBasicPublishOptions)
    }

    func testDeleteCallsDeleteOnChannel() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex = RMQExchange(name: "deletable", type: "direct", options: [], channel: ch)

        ex?.delete()
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([], ch.lastReceivedExchangeDeleteOptions)

        ex?.delete([.ifUnused])
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([.ifUnused], ch.lastReceivedExchangeDeleteOptions)
    }

    func testBindCallsBindOnChannel() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex1 = RMQExchange(name: "ex1", type: "direct", options: [], channel: ch)!
        let ex2 = RMQExchange(name: "ex2", type: "direct", options: [], channel: ch)!

        ex1.bind(ex2)
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("", ch.lastReceivedExchangeBindRoutingKey)

        ex1.bind(ex2, routingKey: "foo")
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("foo", ch.lastReceivedExchangeBindRoutingKey)
    }

    func testUnbindCallsUnbindOnChannel() {
        let ch = ChannelSpy(channelNumber: 1)
        let ex1 = RMQExchange(name: "ex1", type: "direct", options: [], channel: ch)!
        let ex2 = RMQExchange(name: "ex2", type: "direct", options: [], channel: ch)!

        ex1.unbind(ex2)
        XCTAssertEqual("ex1", ch.lastReceivedExchangeUnbindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeUnbindSourceName)
        XCTAssertEqual("", ch.lastReceivedExchangeUnbindRoutingKey)

        ex1.unbind(ex2, routingKey: "foo")
        XCTAssertEqual("ex1", ch.lastReceivedExchangeUnbindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeUnbindSourceName)
        XCTAssertEqual("foo", ch.lastReceivedExchangeUnbindRoutingKey)
    }
}
