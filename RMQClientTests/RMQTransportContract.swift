import XCTest

class RMQTransportContract {
    var transport: RMQTransport

    init(_ aTransport: RMQTransport) {
        transport = aTransport
    }
    
    func connectAndDisconnect() -> RMQTransportContract {
        var connected = false
        try! transport.connect {
            connected = true
        }
        XCTAssert(TestHelper.pollUntil { return connected }, "didn't connect")
        
        transport.close() {
            connected = false
        }
        XCTAssert(TestHelper.pollUntil { return !connected }, "didn't disconnect")

        return self
    }
    
    func throwsWhenWritingButNotConnected() -> RMQTransportContract {
        XCTAssertThrowsError(try transport.write(NSData()) {}) { _ in
            do {
                XCTAssert(true)
            }
        }
        return self
    }
    
    func sendingPreambleStimulatesAConnectionStart() -> RMQTransportContract {
        defer { self.transport.close() {} }
        
        var readData: NSData = NSData()
        var connectionStart = AMQConnectionStart()

        try! self.transport.connect {
            try! self.transport.write(AMQProtocolHeader().amqEncoded()) {
                XCTAssertEqual(0, readData.length)
                self.transport.readFrame() { receivedData in
                    readData = receivedData
                    let parser = AMQParser(data: readData)
                    let frame = AMQFrame(parser: parser)
                    connectionStart = frame.payload as! AMQConnectionStart
                }
            }
        }

        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        XCTAssertEqual(AMQOctet(0), connectionStart.versionMajor)
        XCTAssertEqual(AMQOctet(9), connectionStart.versionMinor)

        return self
    }
}

