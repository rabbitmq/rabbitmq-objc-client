import XCTest

class RMQTransportContract: XCTestCase {

    func newTransport() -> RMQTransport {
        let fake = FakeTransport()
        fake.receive(Fixtures().connectionStart())
        return fake
    }
    
    func testConnectAndDisconnect() {
        let transport = newTransport()
        XCTAssertFalse(transport.isConnected())
        transport.connect()
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "didn't connect")
        transport.close()
        XCTAssert(TestHelper.pollUntil { return !transport.isConnected() }, "didn't disconnect")
    }
    
    func testThrowsWhenWritingButNotConnected() {
        let transport = newTransport()
        
        do {
            try transport.write(NSData()) {}
            XCTFail("No error assigned")
        }
        catch _ as NSError {
            XCTAssert(true)
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    func testSendingPreambleStimulatesAConnectionStart() {
        let transport = newTransport()
        transport.connect()
        defer { transport.close() }
        
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "didn't connect")
        
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        
        var writeSent = false
        try! transport.write(data) {
            writeSent = true
        }
        XCTAssert(TestHelper.pollUntil { return writeSent }, "didn't send write")
        
        var readData: NSData = NSData()
        XCTAssertEqual(0, readData.length)
        transport.readFrame() { receivedData in
            readData = receivedData
        }
        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        let connectionStart = AMQMethodFrame().parse(readData) as! AMQProtocolConnectionStart
        
        XCTAssertEqual(0, connectionStart.versionMajor)
        XCTAssertEqual(9, connectionStart.versionMinor)
    }
    
}

