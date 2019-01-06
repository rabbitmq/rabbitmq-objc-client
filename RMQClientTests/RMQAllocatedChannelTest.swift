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

class RMQAllocatedChannelTest: XCTestCase {

    func testObeysContract() {
        let ch = ChannelHelper.makeChannel(1)
        let contract = RMQChannelContract(ch)

        contract.check()
    }

    func testActivatingActivatesDispatcher() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()

        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        XCTAssertEqual(ch, dispatcher.activatedWithChannel as? RMQAllocatedChannel)
        XCTAssertEqual(delegate, dispatcher.activatedWithDelegate as? ConnectionDelegateSpy)
    }

    func testIncomingSyncFramesetsAreSentToDispatcher() {
        let dispatcher = DispatcherSpy()

        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        let frameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicGetOk(routingKey: "route-me"))
        ch.handle(frameset)

        XCTAssertEqual(frameset, dispatcher.lastFramesetHandled)
    }

    func testOpeningSendsAChannelOpen() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.open()

        XCTAssertEqual(MethodFixtures.channelOpen(), dispatcher.lastSyncMethod as? RMQChannelOpen)
    }

    func testCloseSendsClose() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.close()

        XCTAssertEqual(MethodFixtures.channelClose(), dispatcher.lastSyncMethod as? RMQChannelClose)
    }

    func testIsOpen() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        XCTAssertTrue(ch.isOpen())

        ch.close()
    }

    func testCloseReleasesItsChannelNumberWhenCloseOkReceived() {
        let dispatcher = DispatcherSpy()
        let allocator = ChannelSpyAllocator()

        _ = allocator.allocate() // 0
        _ = allocator.allocate() // 1

        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, allocator: allocator)

        ch.close()

        XCTAssertEqual(2, allocator.channels.count)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelCloseOk()))
        XCTAssertEqual([allocator.channels[0]], allocator.channels)
    }

    func testBlockingCloseSendsCloseAndBlocksUntilCloseOkReceived() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activate(with: nil)

        ch.open()
        ch.blockingClose()

        XCTAssertEqual(MethodFixtures.channelClose(), dispatcher.lastBlockingSyncMethod as? RMQChannelClose)
    }

    func testBlockingCloseReleasesItsChannelNumberFromAllocatorWhenDone() {
        let dispatcher = DispatcherSpy()
        let allocator = ChannelSpyAllocator()

        _ = allocator.allocate() // 0
        _ = allocator.allocate() // 1

        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, allocator: allocator)

        XCTAssertEqual(2, allocator.channels.count)
        ch.blockingClose()
        XCTAssertEqual([allocator.channels[0]], allocator.channels)
    }

    func testBlockingWaitOnDelegatesToDispatcher() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        ch.blockingWait(on: RMQChannelCloseOk.self)

        XCTAssertEqual("RMQChannelCloseOk", dispatcher.lastBlockingWaitOn)
    }

    func testBasicGetSendsBasicGetMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.basicGet("queuey", options: [.noAck]) { _ in }

        XCTAssertEqual(MethodFixtures.basicGet("queuey", options: [.noAck]),
                       dispatcher.lastSyncMethod as? RMQBasicGet)
    }

    func testBasicGetCallsCompletionHandlerWithMessageAndMetadata() {
        let properties = [
            RMQBasicPriority(2),
            RMQBasicHeaders(["some": RMQLongstr("headers")])
        ]
        let getOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicGetOk(routingKey: "my-q", deliveryTag: 1,
                                              exchange: "someex", options: [.redelivered]),
            contentHeader: RMQContentHeader(
                classID: 60,
                bodySize: 123,
                properties: properties
            ),
            contentBodies: [RMQContentBody(data: "hello".data(using: String.Encoding.utf8)!)]
        )
        let expectedMessage = RMQMessage(
            body: "hello".data(using: String.Encoding.utf8),
            consumerTag: "",
            deliveryTag: 1,
            redelivered: true,
            exchangeName: "someex",
            routingKey: "my-q",
            properties: (properties as! [RMQValue & RMQBasicValue])
        )
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        var receivedMessage: RMQMessage?
        ch.basicGet("my-q", options: [.noAck]) { m in
            receivedMessage = m
        }

        dispatcher.lastSyncMethodHandler!(getOkFrameset)

        XCTAssertEqual(expectedMessage, receivedMessage)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let dispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(999, dispatcher: dispatcher, nameGenerator: nameGenerator)
        let consumeOkFrameset1 = RMQFrameset(channelNumber: 999,
                                             method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag1")))
        let consumeOkFrameset2 = RMQFrameset(channelNumber: 999,
                                             method: RMQBasicConsumeOk(consumerTag: RMQShortstr("servertag2")))
        let deliverMethod1 = MethodFixtures.basicDeliver(consumerTag: "tag1", deliveryTag: 1)
        let deliverHeader1 = RMQContentHeader(classID: deliverMethod1.classID(), bodySize: 123, properties: [])
        let deliverBody1 = RMQContentBody(data: "A message for consumer 1".data(using: String.Encoding.utf8)!)
        let deliverFrameset1 = RMQFrameset(channelNumber: 999, method: deliverMethod1,
                                           contentHeader: deliverHeader1, contentBodies: [deliverBody1])
        let deliverMethod2 = MethodFixtures.basicDeliver(consumerTag: "tag2", deliveryTag: 1)
        let deliverHeader2 = RMQContentHeader(classID: deliverMethod2.classID(), bodySize: 123, properties: [])
        let deliverBody2 = RMQContentBody(data: "A message for consumer 2".data(using: String.Encoding.utf8)!)
        let deliverFrameset2 = RMQFrameset(channelNumber: 999, method: deliverMethod2,
                                           contentHeader: deliverHeader2, contentBodies: [deliverBody2])
        let expectedMessage1 = RMQMessage(body: "A message for consumer 1".data(using: String.Encoding.utf8),
                                          consumerTag: "tag1", deliveryTag: 1, redelivered: false, exchangeName: "",
                                          routingKey: "", properties: [])
        let expectedMessage2 = RMQMessage(body: "A message for consumer 2".data(using: String.Encoding.utf8),
                                          consumerTag: "tag2", deliveryTag: 1, redelivered: false, exchangeName: "",
                                          routingKey: "", properties: [])

        ch.activate(with: nil)

        nameGenerator.nextName = "tag1"
        var consumedMessage1: RMQMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage1 = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset1)

        nameGenerator.nextName = "tag2"
        var consumedMessage2: RMQMessage?
        ch.basicConsume("sameq", options: []) { message in
            consumedMessage2 = message
        }
        dispatcher.lastSyncMethodHandler!(consumeOkFrameset2)

        ch.handle(deliverFrameset1)
        ch.handle(deliverFrameset2)
        try! dispatcher.step()

        XCTAssertEqual(expectedMessage1, consumedMessage1)

        try! dispatcher.step()
        XCTAssertEqual(expectedMessage2, consumedMessage2)
    }

    func testBasicPublishSendsAsyncFrameset() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(999, contentBodySize: 4, dispatcher: dispatcher)
        let message = "my great message yo".data(using: String.Encoding.utf8)!
        let notPersistent = RMQBasicDeliveryMode(1)
        let customContentType = RMQBasicContentType("my/content-type")
        let priorityZero = RMQBasicPriority(0)

        let expectedMethod = MethodFixtures.basicPublish("my.q", exchange: "", options: [.mandatory])
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: message.count as NSNumber,
            properties: [notPersistent, customContentType, priorityZero]
        )
        let expectedBodies = [
            RMQContentBody(data: "my g".data(using: String.Encoding.utf8)!),
            RMQContentBody(data: "reat".data(using: String.Encoding.utf8)!),
            RMQContentBody(data: " mes".data(using: String.Encoding.utf8)!),
            RMQContentBody(data: "sage".data(using: String.Encoding.utf8)!),
            RMQContentBody(data: " yo".data(using: String.Encoding.utf8)!)
            ]
        let expectedFrameset = RMQFrameset(
            channelNumber: 999,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        ch.basicPublish(message, routingKey: "my.q", exchange: "",
                        properties: [notPersistent, customContentType, priorityZero],
                        options: [.mandatory])

        XCTAssertEqual(5, dispatcher.lastAsyncFrameset!.contentBodies.count)
        XCTAssertEqual(expectedBodies, dispatcher.lastAsyncFrameset!.contentBodies)
        XCTAssertEqual(expectedFrameset, dispatcher.lastAsyncFrameset!)
    }

    func testPublishReturnsSequenceNumberFromConfirmations() {
        let ch = ChannelHelper.makeChannel(1)
        XCTAssertEqual(0, ch.basicPublish(Data(), routingKey: "", exchange: "", properties: [], options: []))
        XCTAssertEqual(1, ch.basicPublish(Data(), routingKey: "", exchange: "", properties: [], options: []))
    }

    func testPublishHasDefaultProperties() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(999, contentBodySize: 4, dispatcher: dispatcher)

        let corrId: RMQBasicCorrelationId = RMQBasicCorrelationId("my-correlation-id")
        let props: [RMQValue] = [corrId]
        ch.basicPublish(Data(), routingKey: "", exchange: "", properties: props, options: [])

        let expectedProperties: Set<RMQValue> =
            Set(RMQBasicProperties.defaultProperties())
                .union(props)
        let header = dispatcher.lastAsyncFrameset!.contentHeader
        let actualProperties = header.properties

        XCTAssertEqual(expectedProperties.count, actualProperties.count)

        XCTAssertEqual(actualProperties.first(where: { $0 is RMQBasicCorrelationId })!,
                       corrId)
        XCTAssertEqual(actualProperties.first(where: { $0 is RMQBasicDeliveryMode })!,
                       RMQBasicDeliveryMode(1))

    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(999, contentBodySize: 4, dispatcher: dispatcher)
        let messageContent = "12345678".data(using: String.Encoding.utf8)!
        let expectedMethod = MethodFixtures.basicPublish("my.q", exchange: "", options: [])
        let expectedBodyData = messageContent
        let expectedHeader = RMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.count as NSNumber,
            properties: RMQBasicProperties.defaultProperties()
        )
        let expectedBodies = [
            RMQContentBody(data: "1234".data(using: String.Encoding.utf8)!),
            RMQContentBody(data: "5678".data(using: String.Encoding.utf8)!)
            ]
        let expectedFrameset = RMQFrameset(
            channelNumber: 999,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        ch.activate(with: nil)

        ch.basicPublish(messageContent, routingKey: "my.q", exchange: "",
                        properties: RMQBasicProperties.defaultProperties(), options: [])

        XCTAssertEqual(2, dispatcher.lastAsyncFrameset!.contentBodies.count)
        XCTAssertEqual(expectedBodies, dispatcher.lastAsyncFrameset!.contentBodies)
        XCTAssertEqual(expectedFrameset, dispatcher.lastAsyncFrameset!)
    }

    func testBasicQosSendsBasicQosGlobal() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        ch.basicQos(1, global: true)

        XCTAssertEqual(MethodFixtures.basicQos(1, options: [.global]),
                       dispatcher.lastSyncMethod as? RMQBasicQos)
    }

    func testAckSendsABasicAck() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        ch.ack(123, options: [.multiple])

        XCTAssertEqual(MethodFixtures.basicAck(123, options: [.multiple]),
                       dispatcher.lastAsyncMethod as? RMQBasicAck)
    }

    func testRejectSendsABasicReject() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        ch.reject(123, options: [.requeue])

        XCTAssertEqual(MethodFixtures.basicReject(123, options: [.requeue]),
                       dispatcher.lastAsyncMethod as? RMQBasicReject)
    }

    func testNackSendsABasicNack() {
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: delegate)

        ch.nack(123, options: [.requeue])

        XCTAssertEqual(MethodFixtures.basicNack(123, options: [.requeue]),
                       dispatcher.lastAsyncMethod as? RMQBasicNack)
    }

}
