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

class RMQUnallocatedChannelTest: XCTestCase {

    func assertSendsErrorToDelegate(_ delegate: ConnectionDelegateSpy, _ blockIndex: Int) {
        XCTAssertEqual(RMQError.channelUnallocated.rawValue, delegate.lastChannelError?._code)
        XCTAssertEqual("Unallocated channel", delegate.lastChannelError?.localizedDescription,
                       "Didn't get error when running block \(blockIndex)")
    }

    func testSendsErrorToDelegateWhenUsageAttempted() {
        let delegate = ConnectionDelegateSpy()
        let ch = RMQUnallocatedChannel()
        ch.activate(with: delegate)

        // swiftlint:disable opening_brace
        let blocks: [() -> Void] = [
            { ch.ack(1) },
            { ch.afterConfirmed { _, _ in } },
            { ch.basicConsume("foo", options: []) { _ in } },
            { ch.generateConsumerTag() },
            { ch.basicGet("foo", options: []) { _ in } },
            { ch.basicPublish("hi".data(using: String.Encoding.utf8)!,
                              routingKey: "yo", exchange: "hmm",
                              properties: [], options: []) },
            { ch.basicQos(2, global: false) },
            { ch.blockingWait(on: RMQConnectionStart.self) },
            { ch.confirmSelect() },
            { ch.defaultExchange() },
            { ch.exchangeDeclare("", type: "", options: []) },
            { ch.exchangeBind("", destination: "", routingKey: "") },
            { ch.exchangeUnbind("", destination: "", routingKey: "") },
            { ch.fanout("") },
            { ch.direct("") },
            { ch.topic("") },
            { ch.headers("") },
            { ch.exchangeDelete("", options: []) },
            { ch.nack(1) },
            { ch.queue("foo") },
            { ch.queueDelete("foo", options: []) },
            { ch.queueBind("", exchange: "", routingKey: "") },
            { ch.queueUnbind("", exchange: "", routingKey: "") },
            { ch.reject(1) }
        ]

        for (index, run) in blocks.enumerated() {
            delegate.lastChannelError = nil
            run()
            assertSendsErrorToDelegate(delegate, index)
        }
    }

    func testCloseMethodsDoNotProduceError() {
        let delegate = ConnectionDelegateSpy()
        let ch = RMQUnallocatedChannel()
        ch.activate(with: delegate)
        ch.blockingClose()
        XCTAssertNil(delegate.lastChannelError)
    }

    func testIsNotConsideredOpen() {
        let delegate = ConnectionDelegateSpy()
        let ch = RMQUnallocatedChannel()
        ch.activate(with: delegate)

        XCTAssertFalse(ch.isOpen())
    }
}
