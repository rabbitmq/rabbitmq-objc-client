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

class ExchangeDeclarationTest: XCTestCase {

    func testExchangeDeclareSendsAnExchangeDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activate(with: nil)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.durable, .autoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "fanout",
                                                            options: [.durable, .autoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testFanoutDeclaresAFanout() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.fanout("my-exchange", options: [.durable, .autoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "fanout",
                                                            options: [.durable, .autoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testDirectDeclaresADirectExchange() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.direct("my-exchange", options: [.durable, .autoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "direct",
                                                            options: [.durable, .autoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testTopicDeclaresATopicExchange() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.topic("my-exchange", options: [.durable, .autoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "topic",
                                                            options: [.durable, .autoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testHeadersDeclaresAHeadersExchange() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        ch.headers("my-exchange", options: [.durable, .autoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "headers",
                                                            options: [.durable, .autoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testExchangeTypeMethodsReturnFirstWithSameNameEvenIfDifferentOptionsOrTypes() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.activate(with: nil)

        let ex1 = ch.topic("my-exchange", options: [.durable, .autoDelete])
        let ex2 = ch.fanout("my-exchange")
        let ex3 = ch.direct("my-exchange")
        let ex4 = ch.headers("my-exchange", options: [.durable])

        XCTAssertEqual(ex1, ex2)
        XCTAssertEqual(ex2, ex3)
        XCTAssertEqual(ex3, ex4)
    }

    func testExchangeDeleteSendsAnExchangeDelete() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.exchangeDelete("my exchange", options: [.ifUnused])
        XCTAssertEqual(MethodFixtures.exchangeDelete("my exchange", options: [.ifUnused]),
                       dispatcher.lastSyncMethod as? RMQExchangeDelete)
    }

    func testExchangeDeclareAfterDeleteSendsAFreshDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.fanout("my exchange")
        ch.exchangeDelete("my exchange", options: [])
        dispatcher.lastSyncMethod = nil
        ch.fanout("my exchange")
        XCTAssertEqual(MethodFixtures.exchangeDeclare("my exchange", type: "fanout", options: []),
                                                      dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

}
