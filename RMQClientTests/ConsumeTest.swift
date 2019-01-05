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

class ConsumeTest: XCTestCase {
    class CustomConsumer: RMQConsumer {
        var message: RMQMessage?

        override func consume(_ message: RMQMessage!) {
            self.message = message
        }
    }

    func testBasicConsumeSendsBasicConsumeMethod() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)

        nameGenerator.nextName = "a tag"
        ch.basicConsume("foo", options: [.exclusive]) { _ in }

        XCTAssertEqual(MethodFixtures.basicConsume("foo", consumerTag: "a tag", options: [.exclusive]),
                       dispatcher.lastSyncMethod as? RMQBasicConsume)
    }

    func testBasicConsumeWithCustomObjectSendsBasicConsumeMethod() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        nameGenerator.nextName = "a tag"
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumer = CustomConsumer(channel: ch, queueName: "foo", options: [.exclusive])

        ch.basicConsume(consumer!)

        XCTAssertEqual(MethodFixtures.basicConsume("foo", consumerTag: "a tag", options: [.exclusive]),
                       dispatcher.lastSyncMethod as? RMQBasicConsume)
    }

    func testBasicConsumeReturnsConsumerInstanceWithGeneratedTag() {
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, nameGenerator: nameGenerator)
        nameGenerator.nextName = "stubbed tag"

        let consumer = ch.basicConsume("foo", options: [.exclusive]) { _ in }

        XCTAssertEqual("stubbed tag", consumer.tag)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        nameGenerator.nextName = "tag"
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkFrameset = RMQFrameset(channelNumber: 432,
                                            method: RMQBasicConsumeOk(consumerTag: RMQShortstr("tag")))
        let incomingDeliver = deliverFrameset(
            consumerTag: "tag",
            deliveryTag: 456,
            routingKey: "foo",
            content: "Consumed!",
            channelNumber: 432,
            exchange: "my-exchange",
            options: [.redelivered]
        )
        let expectedMessage = RMQMessage(body: "Consumed!".data(using: String.Encoding.utf8),
                                         consumerTag: "tag",
                                         deliveryTag: 456,
                                         redelivered: true,
                                         exchangeName: "my-exchange",
                                         routingKey: "foo",
                                         properties: [])
        var consumedMessage: RMQMessage?
        ch.basicConsume("somequeue", options: []) { message in
            consumedMessage = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        ch.handle(incomingDeliver)
        XCTAssertNil(consumedMessage)
        try! dispatcher.step()

        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testBasicConsumeCallsCustomObjectMethodWhenMessageIsDelivered() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        nameGenerator.nextName = "tag"
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkFrameset = RMQFrameset(channelNumber: 432,
                                            method: RMQBasicConsumeOk(consumerTag: RMQShortstr("tag")))
        let incomingDeliver = deliverFrameset(
            consumerTag: "tag",
            deliveryTag: 456,
            routingKey: "foo",
            content: "Consumed!",
            channelNumber: 432,
            exchange: "my-exchange",
            options: [.redelivered]
        )
        let expectedMessage = RMQMessage(body: "Consumed!".data(using: String.Encoding.utf8),
                                         consumerTag: "tag",
                                         deliveryTag: 456,
                                         redelivered: true,
                                         exchangeName: "my-exchange",
                                         routingKey: "foo",
                                         properties: [])
        let consumer = CustomConsumer(channel: ch, queueName: "somequeue", options: [])
        ch.basicConsume(consumer!)
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        ch.handle(incomingDeliver)
        XCTAssertNil(consumer?.message)
        try! dispatcher.step()

        XCTAssertEqual(expectedMessage, consumer?.message)
    }

    func testBasicConsumeHasNoEffectWhenObjectHasNoDeliveryCallback() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        nameGenerator.nextName = "tag"
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkFrameset = RMQFrameset(channelNumber: 432,
                                            method: RMQBasicConsumeOk(consumerTag: RMQShortstr("tag")))
        let incomingDeliver = deliverFrameset(
            consumerTag: "tag",
            deliveryTag: 456,
            routingKey: "foo",
            content: "Consumed!",
            channelNumber: 432,
            exchange: "my-exchange",
            options: [.redelivered]
        )
        let consumer = RMQConsumer(channel: ch, queueName: "somequeue", options: [])
        ch.basicConsume(consumer!)
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset)

        ch.handle(incomingDeliver)
        try! dispatcher.step()
    }

    func testBasicCancelSendsBasicCancelMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.basicCancel("my tag")

        XCTAssertEqual(MethodFixtures.basicCancel("my tag"), dispatcher.lastSyncMethod as? RMQBasicCancel)
    }

    func testBasicCancelRemovesConsumerWhenCancelOkReceived() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCallCount = 0
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCallCount += 1
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432,
                                                      method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.basicCancel(consumer.tag)

        ch.handle(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo",
                                  content: "message", channelNumber: 432))
        try! dispatcher.finish()

        XCTAssertEqual(1, consumerCallCount)

        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432,
                                                      method: MethodFixtures.basicCancelOk(consumer.tag)))

        ch.handle(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo",
                                  content: "message", channelNumber: 432))
        try! dispatcher.finish()

        XCTAssertEqual(1, consumerCallCount)
    }

    func testServerCancelRemovesExtantConsumer() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(432, dispatcher: dispatcher)

        var consumerCalled = false
        let consumer = ch.basicConsume("my q", options: []) { _ in
            consumerCalled = true
        }
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 432,
                                                      method: MethodFixtures.basicConsumeOk(consumer.tag)))

        ch.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicCancel(consumer.tag)))
        try! dispatcher.step()

        ch.handle(deliverFrameset(consumerTag: consumer.tag, routingKey: "foo",
                                  content: "message", channelNumber: 432))
        try! dispatcher.step()

        XCTAssertFalse(consumerCalled)
    }

    func testCancellationCallbackTriggeredWhenServerSendsCancel() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(123, dispatcher: dispatcher)

        let consumer = CustomConsumer(channel: ch, queueName: "myq", options: [])
        var callCount = 0
        consumer?.onCancellation {
            callCount += 1
        }

        ch.basicConsume(consumer!)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 123,
                                                      method: MethodFixtures.basicConsumeOk((consumer?.tag)!)))

        ch.handle(RMQFrameset(channelNumber: 123, method: MethodFixtures.basicCancel((consumer?.tag)!)))

        XCTAssertEqual(0, callCount)
        try! dispatcher.step()
        XCTAssertEqual(1, callCount)
    }

    // MARK: Helpers

    func deliverFrameset(consumerTag: String, deliveryTag: UInt64 = 123, routingKey: String, content: String,
                         channelNumber: Int, exchange: String = "",
                         options: RMQBasicDeliverOptions = []) -> RMQFrameset {
        let deliverMethod = MethodFixtures.basicDeliver(
            consumerTag: consumerTag,
            deliveryTag: deliveryTag,
            routingKey: routingKey,
            exchange: exchange,
            options: options
        )
        let deliverHeader = RMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let deliverBody = RMQContentBody(data: content.data(using: String.Encoding.utf8)!)
        return RMQFrameset(channelNumber: channelNumber as NSNumber, method: deliverMethod,
                           contentHeader: deliverHeader, contentBodies: [deliverBody])
    }

}
