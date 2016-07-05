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

class ConsumeTest: XCTestCase {

    func testBasicConsumeSendsBasicConsumeMethod() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)

        nameGenerator.nextName = "a tag"
        ch.basicConsume("foo", options: [.Exclusive]) { _ in }

        XCTAssertEqual(MethodFixtures.basicConsume("foo", consumerTag: "a tag", options: [.Exclusive]),
                       dispatcher.lastSyncMethod as? RMQBasicConsume)
    }

    func testBasicConsumeReturnsConsumerInstanceWithGeneratedTag() {
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, nameGenerator: nameGenerator)
        nameGenerator.nextName = "stubbed tag"

        let consumer = ch.basicConsume("foo", options: [.Exclusive]) { _ in }

        XCTAssertEqual("stubbed tag", consumer.tag)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkMethod = RMQBasicConsumeOk(consumerTag: RMQShortstr("tag"))
        let consumeOkFrameset = RMQFrameset(channelNumber: 432, method: consumeOkMethod)
        let incomingDeliver = deliverFrameset(
            consumerTag: "tag",
            deliveryTag: 456,
            routingKey: "foo",
            content: "Consumed!",
            channelNumber: 432,
            exchange: "my-exchange",
            options: [.Redelivered]
        )
        let expectedMessage = RMQMessage(body: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding),
                                         consumerTag: "tag",
                                         deliveryTag: 456,
                                         redelivered: true,
                                         exchangeName: "my-exchange",
                                         routingKey: "foo",
                                         properties: [])

        ch.activateWithDelegate(nil)

        nameGenerator.nextName = "tag"
        var consumedMessage: RMQMessage?
        ch.basicConsume("somequeue", options: []) { message in
            consumedMessage = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        ch.handleFrameset(incomingDeliver)
        XCTAssertNil(consumedMessage)
        try! dispatcher.step()

        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicCancelSendsBasicCancelMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.basicCancel("my tag")

        XCTAssertEqual(MethodFixtures.basicCancel("my tag"), dispatcher.lastSyncMethod as? RMQBasicCancel)
    }

    func testBasicCancelRemovesConsumer() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.basicCancel(consumer.tag)

        ch.handleFrameset(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! dispatcher.step()

        XCTAssertFalse(consumerCalled)
    }

    func testServerCancelRemovesExtantConsumer() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432, method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.handleFrameset(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicCancel(consumer.tag)))
        try! dispatcher.step()

        ch.handleFrameset(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo", content: "message", channelNumber: 432))
        try! dispatcher.step()

        XCTAssertFalse(consumerCalled)
    }

    // MARK: Helpers

    func deliverFrameset(consumerTag consumerTag: String, deliveryTag: UInt64 = 123, routingKey: String, content: String, channelNumber: Int, exchange: String = "", options: RMQBasicDeliverOptions = []) -> RMQFrameset {
        let deliverMethod = MethodFixtures.basicDeliver(
            consumerTag: consumerTag,
            deliveryTag: deliveryTag,
            routingKey: routingKey,
            exchange: exchange,
            options: options
        )
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: content.dataUsingEncoding(NSUTF8StringEncoding)!)
        return RMQFrameset(channelNumber: channelNumber, method: deliverMethod, contentHeader: deliverHeader, contentBodies: [deliverBody])
    }

}
