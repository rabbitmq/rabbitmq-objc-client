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

@objc class EncodableMethod: NSObject, RMQMethod, NSCopying {
    static func propertyClasses() -> [AnyObject] {
        return []
    }
    required convenience init(decodedFrame frame: [AnyObject]) {
        self.init()
    }
    func copyWithZone(zone: NSZone) -> AnyObject {
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
    func amqEncoded() -> NSData {
        let data = NSMutableData()
        data.appendData(RMQShort(10).amqEncoded())
        data.appendData(RMQShort(11).amqEncoded())
        data.appendData(RMQShortstr("foo").amqEncoded())
        return data
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
            RMQBasicTimestamp(NSDate.distantFuture()),
            RMQBasicType("mytype"),
            RMQBasicUserId("fred"),
            RMQBasicAppId("appy"),
            RMQBasicReserved(""),
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
        let payload = RMQContentBody(data: "cyclist's string 🚴🏿".dataUsingEncoding(NSUTF8StringEncoding)!)
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
        XCTAssertEqual(1 + 2 + 4 + 1, payload.amqEncoded().length)
        TestHelper.assertEqualBytes(payload.amqEncoded(), hydrated.amqEncoded())
    }

    func testRoundTripChannelClose() {
        let payload = RMQChannelClose(replyCode: RMQShort(406), replyText: RMQShortstr("PRECONDITION_FAILED - inequivalent arg 'durable' for queue 'rmqclient.integration-tests.E0B5A093-6B2E-402C-84F3-E93B59DF807B-71865-0003F85C24C90FC6' in vhost '/': received 'false' but current is 'true'"), classId: RMQShort(20), methodId: RMQShort(40))
        let data = RMQFrame(channelNumber: 2, payload: payload).amqEncoded()
        let parser = RMQParser(data: data)
        let hydrated = RMQFrame(parser: parser).payload as! RMQChannelClose
        XCTAssertEqual(payload, hydrated)
    }

    func testParserCanReturnLengthOfData() {
        let data = "Ho ho ho 🏈".dataUsingEncoding(NSUTF8StringEncoding)!
        let parser = RMQParser(data: data)

        parser.parseOctet()
        let length = UInt32(data.length) - 1
        let actual = NSString(data: parser.parseLength(length), encoding: NSUTF8StringEncoding)
        XCTAssertEqual("o ho ho 🏈", actual)
    }

    func testEncodeContentHeaderPayload() {
        let classID = RMQShort(60)
        let weight = RMQShort(0)
        let bodySize = RMQLonglong(2)
        let timestamp = RMQBasicTimestamp(NSDate())
        let contentType = RMQBasicContentType("text/plain")
        let contentEncoding = RMQBasicContentEncoding("foo")
        let unsortedProperties: [RMQBasicValue] = [
            timestamp,
            contentEncoding,
            contentType,
        ]
        let payload = RMQContentHeader(
            classID: classID.integerValue,
            bodySize: Int(bodySize.integerValue),
            properties: unsortedProperties
        )

        let expectedData = NSMutableData()
        expectedData.appendData(classID.amqEncoded())
        expectedData.appendData(weight.amqEncoded())
        expectedData.appendData(bodySize.amqEncoded())
        expectedData.appendData(RMQShort(contentType.flagBit() | contentEncoding.flagBit() | timestamp.flagBit()).amqEncoded())
        expectedData.appendData(contentType.amqEncoded())
        expectedData.appendData(contentEncoding.amqEncoded())
        expectedData.appendData(timestamp.amqEncoded())

        TestHelper.assertEqualBytes(expectedData, payload.amqEncoded())
    }

    func testEncodeContentBodyPayloadIsNoOp() {
        let data = "foo".dataUsingEncoding(NSUTF8StringEncoding)!
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
        let unfinishedFrame = "\(type)\(channel)\(size)\(classID)\(methodID)\(payload)".dataUsingEncoding(NSUTF8StringEncoding)!
        var frameEnd = 0xce
        let expectedFrame = unfinishedFrame.mutableCopy() as! NSMutableData
        expectedFrame.appendBytes(&frameEnd, length: 1)

        let encodableMethod = EncodableMethod()
        let frame: NSData = RMQFrame(channelNumber: 0, payload: encodableMethod).amqEncoded()

        TestHelper.assertEqualBytes(expectedFrame, frame)
    }

    func testFramesetEncodingWithContent() {
        let method = MethodFixtures.basicGet()
        let header = RMQContentHeader(classID: 60, bodySize: 123, properties: [RMQBasicContentType("text/plain")])
        let body1 = RMQContentBody(data: "some body".dataUsingEncoding(NSUTF8StringEncoding)!)
        let body2 = RMQContentBody(data: "another body".dataUsingEncoding(NSUTF8StringEncoding)!)
        let frameset = RMQFrameset(
            channelNumber: 1,
            method: method,
            contentHeader: header,
            contentBodies: [body1, body2]
        )
        let expected = NSMutableData()
        expected.appendData(RMQFrame(channelNumber: 1, payload: method).amqEncoded())
        expected.appendData(RMQFrame(channelNumber: 1, payload: header).amqEncoded())
        expected.appendData(RMQFrame(channelNumber: 1, payload: body1).amqEncoded())
        expected.appendData(RMQFrame(channelNumber: 1, payload: body2).amqEncoded())
        let actual = frameset.amqEncoded();
        TestHelper.assertEqualBytes(expected, actual)
    }

    func testFramesetEncodingWithoutContent() {
        let method = MethodFixtures.basicGet()
        let header = RMQContentHeaderNone()
        let ignoredBody = RMQContentBody(data: "some body".dataUsingEncoding(NSUTF8StringEncoding)!)
        let frameset = RMQFrameset(
            channelNumber: 1,
            method: method,
            contentHeader: header,
            contentBodies: [ignoredBody]
        )
        let expected = RMQFrame(channelNumber: 1, payload: method).amqEncoded()
        let actual = frameset.amqEncoded();
        TestHelper.assertEqualBytes(expected, actual)
    }

    func testLongStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        let a = [0x00, 0x00, 0x00, 0x07]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)

        XCTAssertEqual(expectedData, RMQLongstr("abcdefg").amqEncoded())
    }
    
    func testShortStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        var a = 0x07
        expectedData.appendBytes(&a, length: 1)
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        XCTAssertEqual(expectedData, RMQShortstr("abcdefg").amqEncoded())
    }
    
    func testTrueBecomesOne(){
        let expectedData = NSMutableData()
        
        var trueVal = 0x01
        expectedData.appendBytes(&trueVal, length: 1)
        
        XCTAssertEqual(expectedData, RMQBoolean(true).amqEncoded())
    }
    
    func testFalseBecomesZero() {
        let expectedData = NSMutableData()
        
        var falseVal = 0x00
        expectedData.appendBytes(&falseVal, length: 1)
        
        XCTAssertEqual(expectedData, RMQBoolean(false).amqEncoded())
    }

    func testOptionsBecomeBitfieldOctet() {
        var optionsSet: RMQQueueDeclareOptions = []
        optionsSet.insert(.Passive)
        optionsSet.insert(.Durable)
        let method = RMQQueueDeclare(
            reserved1: RMQShort(0),
            queue: RMQShortstr("queuename"),
            options: optionsSet,
            arguments: RMQTable([:])
        )
        let actual = method.amqEncoded()
        let optionsByte = actual.subdataWithRange(NSMakeRange(actual.length - RMQTable([:]).amqEncoded().length - 1, 1))
        TestHelper.assertEqualBytes("\u{03}".dataUsingEncoding(NSUTF8StringEncoding)!, optionsByte)
    }
    
    func testCredentialsEncodedAsRFC2595() {
        let credentials = RMQCredentials(username: "fido🔫﷽", password: "2easy2break📵")
        let expectedData = "\u{00}\u{00}\u{00}\u{1c}\u{00}fido🔫﷽\u{00}2easy2break📵".dataUsingEncoding(NSUTF8StringEncoding)
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
        let expectedData = "\(fieldTableLength)\(fieldPairs)".dataUsingEncoding(NSUTF8StringEncoding)

        let subDict: [String: RMQBoolean] = [
            "ghost": RMQBoolean(false),
            ]
        let dict: [String: RMQValue] = [
            "has_cats": rmqTrue,
            "has_dogs": rmqFalse,
            "mass_hysteria": RMQTable(subDict),
            "sacrifice": RMQLongstr("forty years of darkness"),
            ]
        let fieldTable = RMQTable(dict)

        TestHelper.assertEqualBytes(expectedData!, fieldTable.amqEncoded())
    }

    func testEmptyFieldTableBecomesFourZeroBytes() {
        let expectedData = "\u{00}\u{00}\u{00}\u{00}".dataUsingEncoding(NSUTF8StringEncoding)!
        let fieldTable = RMQTable([:])
        TestHelper.assertEqualBytes(expectedData, fieldTable.amqEncoded())
    }

    func testArrayBecomesLengthPlusFieldValues() {
        let expectedData = "\u{00}\u{00}\u{00}\u{08}S\u{00}\u{00}\u{00}\u{03}foo".dataUsingEncoding(NSUTF8StringEncoding)!
        let array = RMQArray([RMQLongstr("foo")])
        TestHelper.assertEqualBytes(expectedData, array.amqEncoded())
    }

    func testEmptyArrayBecomesFourZeroBytes() {
        let expectedData = "\u{00}\u{00}\u{00}\u{00}".dataUsingEncoding(NSUTF8StringEncoding)!
        let fieldTable = RMQArray([])
        TestHelper.assertEqualBytes(expectedData, fieldTable.amqEncoded())
    }

    func testTimestampBecomes64BitPOSIX() {
        let date = NSDate.distantFuture()
        let timestamp = RMQTimestamp(date)
        let expected = RMQLonglong(UInt64(date.timeIntervalSince1970))

        TestHelper.assertEqualBytes(expected.amqEncoded(), timestamp.amqEncoded())
    }
}
