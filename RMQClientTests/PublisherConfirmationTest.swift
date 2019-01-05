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

class PublisherConfirmationTest: XCTestCase {

    func testConfirmSelectSendsConfirmSelectMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.confirmSelect()

        XCTAssertEqual(MethodFixtures.confirmSelect(), dispatcher.lastSyncMethod as? RMQConfirmSelect)
    }

    func testConfirmSelectEnablesConfirmations() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        XCTAssertFalse(confirmations.isEnabled())
        ch.confirmSelect()
        XCTAssert(confirmations.isEnabled())
    }

    func testCallbackIsPassedToConfirmationsHandler() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        var receivedAcks: Set<NSNumber>?
        var receivedNacks: Set<NSNumber>?
        ch.afterConfirmed { (acks, nacks) in
            receivedAcks = acks
            receivedNacks = nacks
        }

        confirmations.lastReceivedCallback!([1, 2], [3, 4])
        XCTAssertEqual([1, 2], receivedAcks)
        XCTAssertEqual([3, 4], receivedNacks)
    }

    func testEveryPublicationIsCounted() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        XCTAssertEqual(0, confirmations.publicationCount)
        ch.basicPublish("hi there".data(using: String.Encoding.utf8)!, routingKey: "", exchange: "",
                        properties: [], options: [])
        XCTAssertEqual(1, confirmations.publicationCount)
    }

    func testServerAcksAreRecordedOnceDequeued() {
        let confirmations = ConfirmationsSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, confirmations: confirmations)

        let ack = MethodFixtures.basicAck(123, options: [.multiple])
        ch.handle(RMQFrameset(channelNumber: 1, method: ack))

        XCTAssertNil(confirmations.lastReceivedAck)
        try! dispatcher.step()
        XCTAssertEqual(ack, confirmations.lastReceivedAck)
    }

    func testServerNacksAreRecordedOnceDequeued() {
        let confirmations = ConfirmationsSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, confirmations: confirmations)

        let nack = MethodFixtures.basicNack(123, options: [.multiple])
        ch.handle(RMQFrameset(channelNumber: 1, method: nack))

        XCTAssertNil(confirmations.lastReceivedNack)
        try! dispatcher.step()
        XCTAssertEqual(nack, confirmations.lastReceivedNack)
    }

    func testConfirmationCallbackSetsTimeout() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        ch.confirmSelect()

        ch.basicPublish(Data(), routingKey: "", exchange: "", properties: [], options: [])

        ch.afterConfirmed { (_, _) in }
        XCTAssertEqual(30, confirmations.lastReceivedTimeout)

        ch.afterConfirmed(123) { (_, _) in }
        XCTAssertEqual(123, confirmations.lastReceivedTimeout)
    }

}
