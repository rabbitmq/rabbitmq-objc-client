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

class QueueDeclarationTest: XCTestCase {

    func testQueueSendsAQueueDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activate(with: nil)

        ch.queue("bagpuss")

        let expectedMethod = MethodFixtures.queueDeclare("bagpuss", options: [])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

    func testQueueWithEmptyNameGetsClientGeneratedName() {
        let generator = StubNameGenerator()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: generator)

        ch.activate(with: nil)

        generator.nextName = "mouse-organ"
        let rmqQueue = ch.queue("", options: [])

        let expectedMethod = MethodFixtures.queueDeclare("mouse-organ", options: [])
        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueDeclare)
        XCTAssertEqual("mouse-organ", rmqQueue.name)
    }

    func testQueueWithEmptyNameSendsErrorToDelegateOnNameCollision() {
        let generator = StubNameGenerator()
        let delegate = ConnectionDelegateSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, nameGenerator: generator)

        ch.activate(with: delegate)

        generator.nextName = "I-will-dupe"

        ch.queue("", options: [])
        ch.queue("")
        XCTAssertEqual(1, dispatcher.syncMethodsSent.count)

        XCTAssertEqual(RMQError.channelQueueNameCollision.rawValue, delegate.lastChannelError?._code)
    }

    func testQueueWithArguments() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.queue("priority-queue", options: [], arguments: ["x-max-priority": RMQShort(10)])

        XCTAssertEqual(MethodFixtures.queueDeclare("priority-queue", options: [],
                                                   arguments: ["x-max-priority": RMQShort(10)]),
                       dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

    func testQueueDeleteSendsAQueueDelete() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.queueDelete("my queue", options: [.ifUnused])
        XCTAssertEqual(MethodFixtures.queueDelete("my queue", options: [.ifUnused]),
                       dispatcher.lastSyncMethod as? RMQQueueDelete)
    }

    func testQueueDeclareAfterDeleteSendsAFreshDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.queue("my queue")
        ch.queueDelete("my queue", options: [])
        dispatcher.lastSyncMethod = nil
        ch.queue("my queue")
        XCTAssertEqual(MethodFixtures.queueDeclare("my queue", options: []),
                       dispatcher.lastSyncMethod as? RMQQueueDeclare)
    }

}
