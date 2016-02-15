import XCTest

@objc class EncodableMethod: NSObject, AMQMethod, NSCopying {
    var frameArguments: [AnyObject] = [AMQShortstr("foo")]
    static func classID() -> NSNumber {
        return 10
    }
    static func methodID() -> NSNumber {
        return 11
    }
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self
    }
}

class AMQEncodingTest: XCTestCase {

    func testRoundTrip() {
        let method = AMQProtocolConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
        let data = AMQEncoder().encodeMethod(method, channelID: 0)
        let decoder = AMQDecoder(data: data)
        let hydratedMethod = decoder.decodedAMQMethod() as! AMQProtocolConnectionTune
        XCTAssertEqual(method, hydratedMethod)
    }

    func testFraming() {
        let encoder = AMQEncoder()
        
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
        let frame: NSData = encoder.encodeMethod(encodableMethod, channelID: 0)

        TestHelper.assertEqualBytes(expectedFrame, frame)
    }
    
    func testLongStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        let a = [0x00, 0x00, 0x00, 0x07]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)

        XCTAssertEqual(expectedData, AMQLongstr("abcdefg").amqEncoded())
    }
    
    func testShortStringBecomesLengthPlusChars() {
        let expectedData = NSMutableData()
        var a = 0x07
        expectedData.appendBytes(&a, length: 1)
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        XCTAssertEqual(expectedData, AMQShortstr("abcdefg").amqEncoded())
    }
    
    func testTrueBecomesOne(){
        let expectedData = NSMutableData()
        
        var trueVal = 0x01
        expectedData.appendBytes(&trueVal, length: 1)
        
        XCTAssertEqual(expectedData, AMQBoolean(true).amqEncoded())
    }
    
    func testFalseBecomesZero() {
        let expectedData = NSMutableData()
        
        var falseVal = 0x00
        expectedData.appendBytes(&falseVal, length: 1)
        
        XCTAssertEqual(expectedData, AMQBoolean(false).amqEncoded())
    }
    
    func testCredentialsEncodedAsRFC2595() {
        let credentials = AMQCredentials(username: "fido🔫﷽", password: "2easy2break📵")
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
        
        let fieldTable = AMQTable([
            "has_cats": AMQBoolean(true),
            "has_dogs": AMQBoolean(false),
            "mass_hysteria": AMQTable([
                "ghost": AMQBoolean(false),
            ]),
            "sacrifice": AMQLongstr("forty years of darkness"),
        ])

        TestHelper.assertEqualBytes(expectedData!, fieldTable.amqEncoded())
    }
}
