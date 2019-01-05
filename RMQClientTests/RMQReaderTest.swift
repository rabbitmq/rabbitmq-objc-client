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

class RMQReaderTest: XCTestCase {

    func testSkipsServerHeartbeats() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.channelOpenOk()
        let expectedFrameset = RMQFrameset(channelNumber: 42, method: method)

        reader.run()

        transport.serverSendsPayload(RMQHeartbeat(), channelNumber: 0)
        transport.serverSendsPayload(method, channelNumber: 42)

        XCTAssertEqual(
            expectedFrameset,
            frameHandler.lastReceivedFrameset()!,
            "\n\nExpected: \(method)\n\nGot: \(frameHandler.lastReceivedFrameset()!.method)"
        )
    }

    func testSendsDecodedContentlessFramesetToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.connectionStart()
        let expectedFrameset = RMQFrameset(channelNumber: 42, method: method)

        reader.run()

        transport.serverSendsPayload(method, channelNumber: 42)

        XCTAssertEqual(
            expectedFrameset,
            frameHandler.lastReceivedFrameset()!,
            "\n\nExpected: \(method)\n\nGot: \(frameHandler.lastReceivedFrameset()!.method)"
        )
    }

    func testHandlesContentTerminatedByNonContentFrame() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk(routingKey: "my.great.queue")
        let content1 = RMQContentBody(data: "aa".data(using: String.Encoding.utf8)!)
        let content2 = RMQContentBody(data: "bb".data(using: String.Encoding.utf8)!)
        let contentHeader = RMQContentHeader(
            classID: 10,
            bodySize: 999999,
            properties: [
                RMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = RMQFrameset(
            channelNumber: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )
        let nonContent = nonContentPayload()
        let expectedNonContentFrameset = RMQFrameset(channelNumber: 42, method: nonContent)

        reader.run()

        transport
            .serverSendsPayload(method, channelNumber: 42)
            .serverSendsPayload(contentHeader, channelNumber: 42)
            .serverSendsPayload(content1, channelNumber: 42)
            .serverSendsPayload(content2, channelNumber: 42)
            .serverSendsPayload(nonContent, channelNumber: 42)

        XCTAssertEqual(2, frameHandler.receivedFramesets.count)
        XCTAssertEqual(expectedContentFrameset, frameHandler.receivedFramesets[0])
        XCTAssertEqual(expectedNonContentFrameset, frameHandler.receivedFramesets[1])
    }

    func testHandlesContentTerminatedByEndOfDataSize() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)
        let method = MethodFixtures.basicGetOk(routingKey: "my.great.queue")
        let content1 = RMQContentBody(data: "aa".data(using: String.Encoding.utf8)!)
        let content2 = RMQContentBody(data: "bb".data(using: String.Encoding.utf8)!)
        let contentHeader = RMQContentHeader(
            classID: 10,
            bodySize: content1.amqEncoded().count + content2.amqEncoded().count as NSNumber,
            properties: [
                RMQBasicContentType("text/flame")
            ]
        )
        let expectedContentFrameset = RMQFrameset(
            channelNumber: 42,
            method: method,
            contentHeader: contentHeader,
            contentBodies: [content1, content2]
        )

        reader.run()

        transport
            .serverSendsPayload(method, channelNumber: 42)
            .serverSendsPayload(contentHeader, channelNumber: 42)
            .serverSendsPayload(content1, channelNumber: 42)
            .serverSendsPayload(content2, channelNumber: 42)

        XCTAssertEqual([expectedContentFrameset], frameHandler.receivedFramesets)
    }

    func testDeliveryWithZeroBodySizeDoesNotCauseBodyFrameRead() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)

        let deliver = RMQFrame(channelNumber: 42, payload: MethodFixtures.basicDeliver())
        let header = RMQFrame(channelNumber: 42, payload: RMQContentHeader(classID: 60, bodySize: 0, properties: []))

        reader.run()

        transport.serverSendsData(deliver.amqEncoded())

        let before = transport.readCallbacks.count
        transport.serverSendsData(header.amqEncoded())
        let after = transport.readCallbacks.count

        XCTAssertEqual(after, before)
    }

    func testDeliveryWithZeroBodySizeGetsSentToFrameHandler() {
        let transport = ControlledInteractionTransport()
        let frameHandler = FrameHandlerSpy()
        let reader = RMQReader(transport: transport, frameHandler: frameHandler)

        let method = MethodFixtures.basicDeliver()
        let deliver = RMQFrame(channelNumber: 42, payload: method)
        let header = RMQContentHeader(classID: 60, bodySize: 0, properties: [])
        let headerFrame = RMQFrame(channelNumber: 42, payload: header)

        reader.run()

        transport.serverSendsData(deliver.amqEncoded())
        transport.serverSendsData(headerFrame.amqEncoded())

        XCTAssertEqual(RMQFrameset(channelNumber: 42, method: method, contentHeader: header, contentBodies: []),
                       frameHandler.lastReceivedFrameset())
    }

    func nonContentPayload() -> RMQBasicDeliver {
        return RMQBasicDeliver(consumerTag: RMQShortstr(""), deliveryTag: RMQLonglong(0),
                               options: RMQBasicDeliverOptions(), exchange: RMQShortstr(""),
                               routingKey: RMQShortstr("somekey"))
    }
}
