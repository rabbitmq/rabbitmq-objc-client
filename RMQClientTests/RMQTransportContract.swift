import XCTest

class RMQTransportContract: XCTestCase {

    func newTransport() -> RMQTransport {
        return FakeTransport().receive(Fixtures.connectionStart())
    }
    
    func testConnectAndDisconnect() {
        let transport = newTransport()
        var connected = false
        transport.connect(){
            connected = true
        }
        XCTAssert(TestHelper.pollUntil { return connected }, "didn't connect")
        
        transport.close(){
            connected = false
        }
        XCTAssert(TestHelper.pollUntil { return !connected }, "didn't disconnect")
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
        
        defer { transport.close() {} }
        
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        
        var readData: NSData = NSData()
        var connectionStart = AMQProtocolConnectionStart()
        
        transport.connect() {
            try! transport.write(data) {
                XCTAssertEqual(0, readData.length)
                transport.readFrame() { receivedData in
                    readData = receivedData
                    connectionStart = AMQMethodFrame().parse(readData) as! AMQProtocolConnectionStart
                }
            }
        }
        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        XCTAssertEqual(0, connectionStart.versionMajor)
        XCTAssertEqual(9, connectionStart.versionMinor)
    }
}

