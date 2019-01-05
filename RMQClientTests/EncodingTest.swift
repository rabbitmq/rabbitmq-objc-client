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

// swiftlint:disable line_length
@objc class EncodableMethod: NSObject, RMQMethod, NSCopying {
    static func propertyClasses() -> [Any] {
        return []
    }
    required convenience init(decodedFrame frame: [Any]) {
        self.init()
    }
    func copy(with zone: NSZone?) -> Any {
        return self
    }
    func frameTypeID() -> NSNumber {
        return 1
    }
    func classID() -> NSNumber {
        return 999
    }
    func methodID() -> NSNumber {
        return 999
    }
    func syncResponse() -> AnyClass {
        return NSNull.self
    }
    func hasContent() -> Bool {
        return false
    }
    func shouldHaltOnReceipt() -> Bool {
        return false
    }
    func amqEncoded() -> Data {
        let data = NSMutableData()
        data.append(RMQShort(10).amqEncoded())
        data.append(RMQShort(11).amqEncoded())
        data.append(RMQShortstr("foo").amqEncoded())
        return data as Data
    }
}

class EncodingTest: XCTestCase {
    let rmqTrue = RMQBoolean(true)
    let rmqFalse = RMQBoolean(false)

    func testRoundTripMethod() {
        let subDict: [String: RMQLongstr] = ["bar": RMQLongstr("baz")]
        let dict: [String: RMQTable] = [
            "foo": RMQTable(subDict)
        ]
        let payload = RMQConnectionStart(
            versionMajor: RMQOctet(0),
            versionMinor: RMQOctet(9),
            serverProperties: RMQTable(dict),
            mechanisms: RMQLongstr("PLAIN_JANE"),
            locales: RMQLongstr("en_PIRATE")
        )
        let data = RMQFrame(channelNumber: 42, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let frame = RMQFrame(parser: parser)
        let hydrated = frame.payload as! RMQConnectionStart
        XCTAssertEqual(payload, hydrated)
    }

    func testRoundTripContentHeader() {
        let properties: [RMQValue] = [
            RMQBasicContentType("somecontentype"),
            RMQBasicContentEncoding("somecontentencoding"),
            RMQBasicHeaders(["foo": RMQLongstr("bar")]),
            RMQBasicDeliveryMode(3),
            RMQBasicPriority(4),
            RMQBasicCorrelationId("asdf"),
            RMQBasicReplyTo("meplease"),
            RMQBasicExpiration("NEVER!"),
            RMQBasicMessageId("my-message"),
            RMQBasicTimestamp(Date.distantFuture),
            RMQBasicType("mytype"),
            RMQBasicUserId("fred"),
            RMQBasicAppId("appy"),
            RMQBasicReserved("")
        ]
        let payload = RMQContentHeader(
            classID: 2,
            bodySize: 23,
            properties: properties
        )
        let data = RMQFrame(channelNumber: 42, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let hydrated = RMQFrame(parser: parser).payload as! RMQContentHeader
        XCTAssertEqual(payload, hydrated)
    }

    func testRoundTripContentBody() {
        let payload = RMQContentBody(data: "cyclist's string 🚴🏿".data(using: String.Encoding.utf8)!)
        let data = RMQFrame(channelNumber: 321, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let hydrated = RMQFrame(parser: parser).payload as! RMQContentBody
        TestHelper.assertEqualBytes(payload.data, hydrated.data)
    }

    func testRoundTripHeartbeat() {
        let payload = RMQHeartbeat()
        let data = RMQFrame(channelNumber: 0, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let hydrated = RMQFrame(parser: parser).payload as! RMQHeartbeat
        XCTAssertEqual(1 + 2 + 4 + 1, payload.amqEncoded().count)
        TestHelper.assertEqualBytes(payload.amqEncoded(), hydrated.amqEncoded())
    }

    func testRoundTripChannelClose() {
        let msg = "PRECONDITION_FAILED - inequivalent arg 'durable' for queue 'rmqclient.integration-tests.E0B5A093-6B2E-402C-84F3-E93B59DF807B-71865-0003F85C24C90FC6' in vhost '/': received 'false' but current is 'true'"
        let payload = RMQChannelClose(replyCode: RMQShort(406),
                                      replyText: RMQShortstr(msg), classId: RMQShort(20), methodId: RMQShort(40))
        let data = RMQFrame(channelNumber: 2, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let hydrated = RMQFrame(parser: parser).payload as! RMQChannelClose
        XCTAssertEqual(payload, hydrated)
    }

    func testParserCanReturnLengthOfData() {
        let data = "Ho ho ho 🏈".data(using: String.Encoding.utf8)!
        let parser = RMQParser(data: data)

        parser.parseOctet()
        let length = UInt32(data.count) - 1
        let actual = NSString(data: parser.parseLength(length), encoding: String.Encoding.utf8.rawValue)
        XCTAssertEqual("o ho ho 🏈", actual)
    }

    func testEncodeContentHeaderPayload() {
        let classID = RMQShort(60)
        let weight = RMQShort(0)
        let bodySize = RMQLonglong(2)
        let timestamp = RMQBasicTimestamp(Date())
        let contentType = RMQBasicContentType("text/plain")
        let contentEncoding = RMQBasicContentEncoding("foo")
        let unsortedProperties: [RMQBasicValue] = [
            timestamp,
            contentEncoding,
            contentType
        ]
        let payload = RMQContentHeader(
            classID: classID.integerValue as NSNumber,
            bodySize: Int(bodySize.integerValue) as NSNumber,
            properties: unsortedProperties
        )

        let expectedData = NSMutableData()
        expectedData.append(classID.amqEncoded())
        expectedData.append(weight.amqEncoded())
        expectedData.append(bodySize.amqEncoded())
        expectedData.append(RMQShort(contentType.flagBit() | contentEncoding.flagBit() |
                                     timestamp.flagBit()).amqEncoded())
        expectedData.append(contentType.amqEncoded())
        expectedData.append(contentEncoding.amqEncoded())
        expectedData.append(timestamp.amqEncoded())

        TestHelper.assertEqualBytes(expectedData as Data, payload.amqEncoded())
    }

    func testEncodeContentBodyPayloadIsNoOp() {
        let data = "foo".data(using: String.Encoding.utf8)!
        let payload = RMQContentBody(data: data)
        TestHelper.assertEqualBytes(data, payload.amqEncoded())
    }

    func testFraming() {
        let type = "\u{1}"
        let channel = "\u{0}\u{0}"
        let size = "\u{0}\u{0}\u{0}\u{8}"
        let classID = "\u{0}\u{A}"
        let methodID = "\u{0}\u{B}"
        let payload = "\u{3}foo"
        let unfinishedFrame = "\(type)\(channel)\(size)\(classID)\(methodID)\(payload)"
            .data(using: String.Encoding.utf8)!
        var frameEnd = 0xce
        let expectedFrame = (unfinishedFrame as NSData).mutableCopy() as! NSMutableData
        expectedFrame.append(&frameEnd, length: 1)

        let encodableMethod = EncodableMethod()
        let frame: Data = RMQFrame(channelNumber: 0, payload: encodableMethod).amqEncoded()

        TestHelper.assertEqualBytes(expectedFrame as Data, frame)
    }

    func testFramesetEncodingWithContent() {
        let method = MethodFixtures.basicGet()
        let header = RMQContentHeader(classID: 60, bodySize: 123, properties: [RMQBasicContentType("text/plain")])
        let body1 = RMQContentBody(data: "some body".data(using: String.Encoding.utf8)!)
        let body2 = RMQContentBody(data: "another body".data(using: String.Encoding.utf8)!)
        let frameset = RMQFrameset(
            channelNumber: 1,
            method: method,
            contentHeader: header,
            contentBodies: [body1, body2]
        )
        let expected = NSMutableData()
        expected.append(RMQFrame(channelNumber: 1, payload: method).amqEncoded())
        expected.append(RMQFrame(channelNumber: 1, payload: header).amqEncoded())
        expected.append(RMQFrame(channelNumber: 1, payload: body1).amqEncoded())
        expected.append(RMQFrame(channelNumber: 1, payload: body2).amqEncoded())
        let actual = frameset.amqEncoded()
        TestHelper.assertEqualBytes(expected as Data, actual)
    }

    func testFramesetEncodingWithoutContent() {
        let method = MethodFixtures.basicGet()
        let header = RMQContentHeaderNone()
        let ignoredBody = RMQContentBody(data: "some body".data(using: String.Encoding.utf8)!)
        let frameset = RMQFrameset(
            channelNumber: 1,
            method: method,
            contentHeader: header,
            contentBodies: [ignoredBody]
        )
        let expected = RMQFrame(channelNumber: 1, payload: method).amqEncoded()
        let actual = frameset.amqEncoded()
        TestHelper.assertEqualBytes(expected, actual)
    }

    func testLongStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        let a = [0x00, 0x00, 0x00, 0x07]
        for var b in a {
            expectedData.append(&b, length: 1)
        }

        expectedData.append("abcdefg".data(using: String.Encoding.ascii)!)

        XCTAssertEqual(expectedData as Data, RMQLongstr("abcdefg").amqEncoded())
    }

    func testShortStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        var a = 0x07
        expectedData.append(&a, length: 1)

        expectedData.append("abcdefg".data(using: String.Encoding.ascii)!)

        XCTAssertEqual(expectedData as Data, RMQShortstr("abcdefg").amqEncoded())
    }

    func testTrueBecomesOne() {
        let expectedData = NSMutableData()

        var trueVal = 0x01
        expectedData.append(&trueVal, length: 1)

        XCTAssertEqual(expectedData as Data, RMQBoolean(true).amqEncoded())
    }

    func testFalseBecomesZero() {
        let expectedData = NSMutableData()

        var falseVal = 0x00
        expectedData.append(&falseVal, length: 1)

        XCTAssertEqual(expectedData as Data, RMQBoolean(false).amqEncoded())
    }

    func testOptionsBecomeBitfieldOctet() {
        var optionsSet: RMQQueueDeclareOptions = []
        optionsSet.insert(.passive)
        optionsSet.insert(.durable)
        let method = RMQQueueDeclare(
            reserved1: RMQShort(0),
            queue: RMQShortstr("queuename"),
            options: optionsSet,
            arguments: RMQTable([:])
        )
        let actual = method.amqEncoded()
        let optionsRangeStart = (actual.count - RMQTable([:]).amqEncoded().count - 1)
        let optionsByte = actual.subdata(in: optionsRangeStart..<optionsRangeStart+1)
        TestHelper.assertEqualBytes("\u{03}".data(using: String.Encoding.utf8)!, optionsByte)
    }

    func testCredentialEncoding() {
        let credentials = RMQCredentials(username: "joe", password: "s3k7et")
        let expectedData = "\u{00}\u{00}\u{00}\u{0B}\u{00}joe\u{00}s3k7et".data(using: String.Encoding.utf8)
        TestHelper.assertEqualBytes(expectedData!, credentials.amqEncoded())
    }

    func testCredentialEncodingWithEmoji() {
        let credentials = RMQCredentials(username: "tiger 🐯", password: "bee 🐝")
        let expectedData = "\u{00}\u{00}\u{00}\u{14}\u{00}tiger 🐯\u{00}bee 🐝".data(using: String.Encoding.utf8)
        TestHelper.assertEqualBytes(expectedData!, credentials.amqEncoded())
    }

    func testCredentialEncodingWithCyrillics() {
        let credentials = RMQCredentials(username: "кириллическое имя", password: "секрет")
        let expectedData = "\u{00}\u{00}\u{00}\u{2F}\u{00}кириллическое имя\u{00}секрет".data(using: String.Encoding.utf8)
        TestHelper.assertEqualBytes(expectedData!, credentials.amqEncoded())
    }

    func testFieldTableBecomesLengthPlusFieldPairs() {
        let fieldTableLength             = "\u{00}\u{00}\u{00}\u{57}"
        let cats                         = "\u{08}has_catst\u{01}"
        let dogs                         = "\u{08}has_dogst\u{00}"
        let massHysteriaKeyLength        = "\u{0D}"
        let massHysteriaTableLength      = "\u{00}\u{00}\u{00}\u{08}"
        let ghost                        = "\u{05}ghostt\u{00}"
        let sacrifice                    = "\u{09}sacrificeS\u{00}\u{00}\u{00}\u{17}forty years of darkness"

        let massHysteria = "\(massHysteriaKeyLength)mass_hysteriaF\(massHysteriaTableLength)\(ghost)"
        let fieldPairs = "\(cats)\(dogs)\(massHysteria)\(sacrifice)"
        let expectedData = "\(fieldTableLength)\(fieldPairs)".data(using: String.Encoding.utf8)

        let subDict: [String: RMQBoolean] = [
            "ghost": RMQBoolean(false)
            ]
        let dict: [String: RMQValue] = [
            "has_cats": rmqTrue,
            "has_dogs": rmqFalse,
            "mass_hysteria": RMQTable(subDict),
            "sacrifice": RMQLongstr("forty years of darkness")
            ]
        let fieldTable = RMQTable(dict as! [String: RMQValue & RMQFieldValue])

        TestHelper.assertEqualBytes(expectedData!, fieldTable.amqEncoded())
    }

    func testEmptyFieldTableBecomesFourZeroBytes() {
        let expectedData = "\u{00}\u{00}\u{00}\u{00}".data(using: String.Encoding.utf8)!
        let fieldTable = RMQTable([:])
        TestHelper.assertEqualBytes(expectedData, fieldTable.amqEncoded())
    }

    func testArrayBecomesLengthPlusFieldValues() {
        let expectedData = "\u{00}\u{00}\u{00}\u{08}S\u{00}\u{00}\u{00}\u{03}foo".data(using: String.Encoding.utf8)!
        let array = RMQArray([RMQLongstr("foo")])
        TestHelper.assertEqualBytes(expectedData, array.amqEncoded())
    }

    func testEmptyArrayBecomesFourZeroBytes() {
        let expectedData = "\u{00}\u{00}\u{00}\u{00}".data(using: String.Encoding.utf8)!
        let fieldTable = RMQArray([])
        TestHelper.assertEqualBytes(expectedData, fieldTable.amqEncoded())
    }

    func testTimestampBecomes64BitPOSIX() {
        let date = Date.distantFuture
        let timestamp = RMQTimestamp(date)
        let expected = RMQLonglong(UInt64(date.timeIntervalSince1970))

        TestHelper.assertEqualBytes(expected.amqEncoded(), timestamp.amqEncoded())
    }
}
