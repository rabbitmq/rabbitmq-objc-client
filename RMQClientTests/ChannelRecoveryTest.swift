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

class ChannelRecoveryTest: XCTestCase {

    func testDispatcherIsDisabledDuringRecovery() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)

        ch.prepareForRecovery()
        XCTAssert(dispatcher.disabled)

        ch.recover()

        XCTAssert(dispatcher.disabled)
        try! recoveryDispatcher.step()
        XCTAssertFalse(dispatcher.disabled)
    }

    func testCommandDispatcherIsUsedAfterRecovery() {
        let commandDispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: commandDispatcher, recoveryDispatcher: recoveryDispatcher)

        ch.recover()
        try! recoveryDispatcher.step()

        commandDispatcher.syncMethodsSent = []
        recoveryDispatcher.syncMethodsSent = []
        ch.basicQos(1, global: true)
        XCTAssertEqual(1, commandDispatcher.syncMethodsSent.count)
        XCTAssertEqual(0, recoveryDispatcher.syncMethodsSent.count)
    }

    func testReopensChannel() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, recoveryDispatcher: dispatcher)
        ch.recover()

        XCTAssertEqual(MethodFixtures.channelOpen(), dispatcher.syncMethodsSent[0] as? RMQChannelOpen)
    }

    func testRecoversEntitiesInCreationOrder() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)

        ch.basicQos(2, global: false) // 2 per consumer
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))

        ch.basicQos(3, global: true)  // 3 per channel
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))

        ch.confirmSelect()

        let e1 = ch.direct("ex1")
        let e2 = ch.direct("ex2")

        e2.bind(e1)

        let q = ch.queue("q")

        q.bind(e2)
        q.bind(e2, routingKey: "foobar")

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssertEqual(MethodFixtures.basicQos(2, options: []),
                       recoveryDispatcher.syncMethodsSent[1] as? RMQBasicQos)
        XCTAssertEqual(MethodFixtures.basicQos(3, options: [.Global]),
                       recoveryDispatcher.syncMethodsSent[2] as? RMQBasicQos)

        XCTAssertEqual(MethodFixtures.confirmSelect(),
                       recoveryDispatcher.syncMethodsSent[3] as? RMQConfirmSelect)

        let expectedExchangeDeclares: Set<RMQExchangeDeclare> = [MethodFixtures.exchangeDeclare("ex1", type: "direct", options: []),
                                                                 MethodFixtures.exchangeDeclare("ex2", type: "direct", options: [])]
        let actualExchangeDeclares: Set<RMQExchangeDeclare>   = [recoveryDispatcher.syncMethodsSent[4] as! RMQExchangeDeclare,
                                                                 recoveryDispatcher.syncMethodsSent[5] as! RMQExchangeDeclare]
        XCTAssertEqual(expectedExchangeDeclares, actualExchangeDeclares)

        XCTAssertEqual(MethodFixtures.exchangeBind("ex1", destination: "ex2", routingKey: ""),
                       recoveryDispatcher.syncMethodsSent[6] as? RMQExchangeBind)

        XCTAssertEqual(MethodFixtures.queueDeclare("q", options: []),
                       recoveryDispatcher.syncMethodsSent[7] as? RMQQueueDeclare)

        let expectedQueueBinds: Set<RMQQueueBind> = [MethodFixtures.queueBind("q", exchangeName: "ex2", routingKey: ""),
                                                     MethodFixtures.queueBind("q", exchangeName: "ex2", routingKey: "foobar")]
        let actualQueueBinds: Set<RMQQueueBind>   = [recoveryDispatcher.syncMethodsSent[8] as! RMQQueueBind,
                                                     recoveryDispatcher.syncMethodsSent[9] as! RMQQueueBind]
        XCTAssertEqual(expectedQueueBinds, actualQueueBinds)
    }

    func testDoesNotReinstatePrefetchSettingsIfNoneSet() {
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, recoveryDispatcher: recoveryDispatcher)
        ch.recover()

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0.isKindOfClass(RMQBasicQos.self) })
    }

    func testDoesNotReinstateConfirmationsIfNotSet() {
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, recoveryDispatcher: recoveryDispatcher)
        ch.recover()

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0.isKindOfClass(RMQConfirmSelect.self) })
    }

    func testInformsConfirmationsHandlerOfConnectivityLoss() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)
        ch.confirmSelect()
        ch.recover()

        XCTAssert(confirmations.recoverCalled)
    }

    func testRedeclaresExchangesThatHadNotBeenDeleted() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)
        ch.fanout("ex1")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))
        ch.headers("ex2", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))
        ch.headers("ex3", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))

        ch.exchangeDelete("ex2", options: [])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeleteOk()))

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeDeclare == MethodFixtures.exchangeDeclare("ex1", type: "fanout", options: []) })
        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeDeclare == MethodFixtures.exchangeDeclare("ex3", type: "headers", options: [.AutoDelete]) })

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeDeclare == MethodFixtures.exchangeDeclare("ex2", type: "headers", options: [.AutoDelete]) })
    }

    func testRedeclaredExchangesAreStillMemoized() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)
        ch.fanout("a", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))

        ch.recover()

        recoveryDispatcher.syncMethodsSent = []
        ch.fanout("a", options: [.AutoDelete])
        XCTAssertEqual(0, recoveryDispatcher.syncMethodsSent.count)
    }

    func testRebindsExchangesNotPreviouslyUnbound() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)

        let a = ch.direct("a")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))
        let b = ch.direct("b")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))
        let c = ch.direct("c")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))
        let d = ch.direct("d")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))

        b.bind(a)
        let bindBToA = MethodFixtures.exchangeBind("a", destination: "b", routingKey: "")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: bindBToA))

        c.bind(a)
        let bindCToA = MethodFixtures.exchangeBind("a", destination: "c", routingKey: "")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: bindCToA))

        d.bind(a, routingKey: "123")
        let bindDToA = MethodFixtures.exchangeBind("a", destination: "d", routingKey: "123")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: bindDToA))

        c.unbind(a)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeUnbind("a", destination: "c", routingKey: "")))

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeBind == bindBToA })
        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeBind == bindDToA })

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQExchangeBind == bindCToA })
    }
    
    func testRedeclaresQueuesThatHadNotBeenDeleted() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)
        ch.queue("a", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("a")))

        ch.queue("b")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("b")))

        ch.queue("c", options: [], arguments: ["x-message-ttl": RMQShort(1000)])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("c")))

        ch.queueDelete("b", options: [.IfUnused])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeleteOk(123)))

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("a", options: [.AutoDelete]) })
        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("c", options: [], arguments: ["x-message-ttl": RMQShort(1000)]) })
        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueDeclare == MethodFixtures.queueDeclare("b", options: []) })
    }

    func testRedeclaredQueuesAreStillMemoized() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)
        ch.queue("a", options: [.AutoDelete])
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("a")))

        ch.recover()

        recoveryDispatcher.syncMethodsSent = []
        ch.queue("a", options: [.AutoDelete])
        XCTAssertEqual(0, recoveryDispatcher.syncMethodsSent.count)
    }
    
    func testRebindsQueuesNotPreviouslyUnbound() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher)
        let q1 = ch.queue("a")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("a")))
        let q2 = ch.queue("b")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("b")))
        let q3 = ch.queue("c")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueDeclareOk("c")))
        let ex = ch.direct("foo")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.exchangeDeclareOk()))

        q1.bind(ex)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueBindOk()))
        q2.bind(ex)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueBindOk()))
        q3.bind(ex, routingKey: "hello")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueBindOk()))

        q2.unbind(ex)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.queueUnbindOk()))

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueBind == MethodFixtures.queueBind("a", exchangeName: "foo", routingKey: "") })
        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueBind == MethodFixtures.queueBind("c", exchangeName: "foo", routingKey: "hello") })

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQQueueBind == MethodFixtures.queueBind("b", exchangeName: "foo", routingKey: "") })
    }

    func testRedeclaresConsumersNotPreviouslyCancelledByClientOrServer() {
        let dispatcher = DispatcherSpy()
        let recoveryDispatcher = DispatcherSpy()
        let nameGenerator = StubNameGenerator()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, recoveryDispatcher: recoveryDispatcher, nameGenerator: nameGenerator)

        let createContext = (ch, dispatcher, nameGenerator)
        createConsumer("consumer1", createContext)
        createConsumer("consumer2", createContext, [.Exclusive])
        createConsumer("consumer3", createContext)
        createConsumer("consumer4", createContext, [.Exclusive])

        ch.basicCancel("consumer2")
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicCancelOk("consumer2")))

        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicCancel("consumer3")))
        try! dispatcher.step()

        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer1", options: []) })
        XCTAssert(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer4", options: [.Exclusive]) })

        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer2", options: [.Exclusive]) })
        XCTAssertFalse(recoveryDispatcher.syncMethodsSent.contains { $0 as? RMQBasicConsume == MethodFixtures.basicConsume("q", consumerTag: "consumer3", options: []) })
    }

    private func createConsumer(consumerTag: String,
                                _ context: (channel: RMQAllocatedChannel, dispatcher: DispatcherSpy, nameGenerator: StubNameGenerator),
                                  _ options: RMQBasicConsumeOptions = []) {
        context.nameGenerator.nextName = consumerTag
        context.channel.basicConsume("q", options: options) { _ in }
        context.dispatcher.lastSyncMethodHandler!(
            RMQFrameset(
                channelNumber: context.channel.channelNumber,
                method: MethodFixtures.basicConsumeOk(consumerTag)
            )
        )
    }

}
