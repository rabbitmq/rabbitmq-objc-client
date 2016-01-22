import XCTest

class RMQTransportContract: XCTestCase {
    override func performTest(run: XCTestRun) {
        if self.dynamicType != RMQTransportContract.self {
            super.performTest(run)
        }
    }

    func newTransport() -> RMQTransport {
        XCTFail("must implement newTransport() for this test")
        return RMQTCPSocketTransport()
    }
    
    func pollUntil(checker: () -> Bool) -> Bool {
        for _ in 1...10 {
            if checker() {
                return true
            } else {
                NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.5))
            }
        }
        return false
    }
    
    func testConnectAndDisconnect() {
        let transport = newTransport()
        XCTAssertFalse(transport.isConnected())
        transport.connect()
        XCTAssert(pollUntil { transport.isConnected() }, "didn't connect")
        transport.close()
        XCTAssert(pollUntil { !transport.isConnected() }, "didn't disconnect")
    }
    
    func testSendingPreambleStimulatesAConnectionStart() {
        let transport = newTransport()
        transport.connect()
        defer { transport.close() }
        
        XCTAssert(pollUntil { transport.isConnected() }, "didn't connect")
        
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        
        var writeSent = false
        transport.write(data) {
            writeSent = true
        }
        XCTAssert(pollUntil { writeSent }, "didn't send write")
        
        var readData: NSData = NSData()
        XCTAssertEqual(0, readData.length)
        transport.readFrame() { receivedData in
            readData = receivedData
        }
        XCTAssert(pollUntil { readData.length > 0 }, "didn't read")
        let connectionStart = AMQMethodFrame().parse(readData) as! AMQProtocolConnectionStart
        
        XCTAssertEqual(0, connectionStart.versionMajor)
        XCTAssertEqual(9, connectionStart.versionMinor)
    }
    
}

