import XCTest

class AMQParserTest: XCTestCase {

    func testShortString() {
        let s = "PRECONDITION_FAILED - inequivalent arg 'durable' for queue 'rmqclient.integration-tests.E0B5A093-6B2E-402C-84F3-E93B59DF807B-71865-0003F85C24C90FC6' in vhost '/': received 'false' but current is 'true'"
        let data = NSMutableData()
        var stringLength = s.characters.count
        data.appendBytes(&stringLength, length: 1)
        data.appendData(s.dataUsingEncoding(NSUTF8StringEncoding)!)
        data.appendData("stuffthatshouldn'tbeparsed".dataUsingEncoding(NSUTF8StringEncoding)!)

        let parser = AMQParser(data: data)
        XCTAssertEqual(s, parser.parseShortString())
    }

}
