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

class RMQTransactionalConfirmationsTest: XCTestCase {

    func testAcksAndNacksArePassedToCallback() {
        let confirms = RMQTransactionalConfirmations(delay: FakeSerialQueue())

        confirms?.enable()
        for _ in 1...5 { _ = confirms?.addPublication() }

        var acks: Set<NSNumber> = []
        var nacks: Set<NSNumber> = []
        confirms?.addCallback(withTimeout: 10) { (a, n) in
            acks = a!
            nacks = n!
        }

        confirms?.ack(MethodFixtures.basicAck(1, options: []))
        XCTAssertEqual([], acks)
        XCTAssertEqual([], nacks)

        confirms?.nack(MethodFixtures.basicNack(2, options: []))
        confirms?.ack(MethodFixtures.basicAck(5, options: [.multiple]))

        XCTAssertEqual([1, 3, 4, 5], acks)
        XCTAssertEqual([2], nacks)
    }

    func testAddingAPublicationHasNoEffectOnConfirmationCallbackBeforeConfirmationsEnabled() {
        let confirms = RMQTransactionalConfirmations(delay: FakeSerialQueue())

        _ = confirms?.addPublication()
        confirms?.enable()
        _ = confirms?.addPublication()

        var acks: Set<NSNumber> = []
        confirms?.addCallback(withTimeout: 10) { (a, _) in
            acks = a!
        }

        confirms?.ack(MethodFixtures.basicAck(1, options: []))

        XCTAssertEqual(1, acks.count)
    }

    func testAddingPublicationBeforeConfirmationsEnabledReturns0() {
        let confirms = RMQTransactionalConfirmations(delay: FakeSerialQueue())
        XCTAssertEqual(0, confirms?.addPublication())
    }

    func testAddingPublicationAfterConfirmationsEnabledReturnsSequenceNumber() {
        let confirms = RMQTransactionalConfirmations(delay: FakeSerialQueue())
        _ = confirms?.addPublication()
        confirms?.enable()
        XCTAssertEqual(1, confirms?.addPublication())
        XCTAssertEqual(2, confirms?.addPublication())
    }

    func testEachCallbackReceivesAcksForPublicationsSinceLastCallbackSet() {
        let confirms = RMQTransactionalConfirmations(delay: FakeSerialQueue())

        confirms?.enable()
        _ = confirms?.addPublication() // 1
        _ = confirms?.addPublication() // 2

        var firstAcks: Set<NSNumber> = []
        var firstNacks: Set<NSNumber> = []
        confirms?.addCallback(withTimeout: 10) { (a, n) in
            firstAcks = a!
            firstNacks = n!
        }

        _ = confirms?.addPublication() // 3
        _ = confirms?.addPublication() // 4

        var secondAcks: Set<NSNumber> = []
        var secondNacks: Set<NSNumber> = []
        confirms?.addCallback(withTimeout: 10) { (a, n) in
            secondAcks = a!
            secondNacks = n!
        }

        confirms?.ack(MethodFixtures.basicAck(1, options: []))          // ack 1
        confirms?.nack(MethodFixtures.basicNack(3, options: []))        // nack 3
        confirms?.ack(MethodFixtures.basicAck(4, options: [.multiple])) // ack 2 and 4

        XCTAssertEqual([1, 2], firstAcks)
        XCTAssertEqual([], firstNacks)
        XCTAssertEqual([4], secondAcks)
        XCTAssertEqual([3], secondNacks)
    }

    func testCallbackThatTimedOutCannotBeRetriggeredViaAcksOrNacks() {
        let q = FakeSerialQueue()
        let confirms = RMQTransactionalConfirmations(delay: q)

        _ = confirms?.enable()
        _ = confirms?.addPublication()

        var callCount = 0
        confirms?.addCallback(withTimeout: 10) { (_, _) in
            callCount += 1
        }

        q.delayedItems[0]()
        confirms?.ack(MethodFixtures.basicAck(1, options: []))
        confirms?.nack(MethodFixtures.basicNack(1, options: []))

        XCTAssertEqual(1, callCount)
    }

    // See this Bunny commit for an explanation:
    // https://github.com/ruby-amqp/bunny/commit/5e6d2b069cc17f44085e1778a0f6cad133a00dc1
    func testRecoveryIgnoresUnconfirmedTagsAndKeepsAnOffset() {
        let q = FakeSerialQueue()
        let confirms = RMQTransactionalConfirmations(delay: q)

        confirms?.enable()
        for i in 1...4 {
            _ = confirms?.addPublication()
            confirms?.ack(MethodFixtures.basicAck(UInt64(i), options: []))
        }

        // These become nacks because they don't get acked or nacked by server before the timeout occurs.
        // This is different behaviour to e.g. Bunny
        for _ in 5...8 {
            _ = confirms?.addPublication()
        }

        confirms?.recover()

        let expectedOffset = 8
        for i in 9...10 {
            _ = confirms?.addPublication()
            let serverDeliveryTag = UInt64(i - expectedOffset)
            confirms?.ack(MethodFixtures.basicAck(serverDeliveryTag, options: []))
        }

        for _ in 11...15 {
            _ = confirms?.addPublication()
        }

        // This is the server nacking 3-7, which is 11-15 in the client's terms.
        confirms?.nack(MethodFixtures.basicNack(7, options: [.multiple]))

        var acks: Set<NSNumber>?
        var nacks: Set<NSNumber>?

        // We want to trigger a timeout, because we lost items during recovery that can't be counted.
        confirms?.addCallback(withTimeout: 60) { (a, n) in
            acks = a
            nacks = n
        }

        q.delayedItems[0]()

        XCTAssertEqual([1, 2, 3, 4, 9, 10], acks)

        // We expect the lost items 5-8 to arrive as nacks.
        XCTAssertEqual([5, 6, 7, 8, 11, 12, 13, 14, 15], nacks)
    }
}
