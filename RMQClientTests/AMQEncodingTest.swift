import XCTest

class AMQEncodingTest: XCTestCase {
    
    func testLongStringBecomesLengthPlusChars() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        let a = [0x00, 0x00, 0x00, 0x07]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let longString = [
            "type": "long-string",
            "value": "abcdefg",
        ]
        
        encoder.encodeObject(longString, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testShortStringBecomesLengthPlusChars() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        var a = 0x07
        expectedData.appendBytes(&a, length: 1)
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let shortString = [
            "type": "short-string",
            "value": "abcdefg",
        ]
        
        encoder.encodeObject(shortString, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testAppend() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var shortLength = 0x03
        expectedData.appendBytes(&shortLength, length: 1)
        expectedData.appendData("abc".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let a = [0x00, 0x00, 0x00, 0x04]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        expectedData.appendData("defg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let shortString = [
            "type": "short-string",
            "value": "abc",
        ]
        let longString = [
            "type": "long-string",
            "value": "defg",
        ]
        
        encoder.encodeObject(shortString, forKey: "foo")
        encoder.encodeObject(longString, forKey: "bar")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testTrueBecomesOne(){
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var trueVal = 0x01
        expectedData.appendBytes(&trueVal, length: 1)
        
        let boolType = [
            "type" : "boolean",
            "value" : true,
        ]
        
        encoder.encodeObject(boolType, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testFalseBecomesZero() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var falseVal = 0x00
        expectedData.appendBytes(&falseVal, length: 1)
        
        let boolType = [
            "type" : "boolean",
            "value" : false,
        ]
        
        encoder.encodeObject(boolType, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testFieldValuePairBecomesFieldNameThenFieldValue() {
        let encoder = AMQEncoder()

        let expectedData = "\u{08}has_catst\u{01}".dataUsingEncoding(NSASCIIStringEncoding)

        let input = [
            "type": "field-value-pair",
            "key": "has_cats",
            "value-type": "boolean",
            "value": true
        ]
        encoder.encodeObject(input, forKey: "foobar")
        XCTAssertEqual(expectedData, encoder.data)
    }

    func testFieldTableBecomesSeriesOfKeyValues() {
        let encoder = AMQEncoder()
        
        let expectedData = "\u{31}\u{00}\u{00}\u{00}\u{08}has_catst\u{01}\u{08}has_dogst\u{00}\u{0D}mass_hysteriaF\u{08}\u{00}\u{00}\u{00}\u{05}ghostt\u{00}".dataUsingEncoding(NSASCIIStringEncoding)
        
        let fieldTableType = [
            "type" : "field-table",
            "value" : [
                [
                    "type": "field-value-pair",
                    "key": "has_cats",
                    "value-type": "boolean",
                    "value": true
                ],
                [
                    "type": "field-value-pair",
                    "key": "has_dogs",
                    "value-type": "boolean",
                    "value": false
                ],
                [
                    "type": "field-value-pair",
                    "key": "mass_hysteria",
                    "value-type": "field-table",
                    "value": [
                        [
                            "type": "field-value-pair",
                            "key": "ghost",
                            "value-type": "boolean",
                            "value": false
                        ]
                    ]
                ]
            ]
        ]
        
        encoder.encodeObject(fieldTableType, forKey: "murray")
        XCTAssertEqual(expectedData, encoder.data)
    }
}
