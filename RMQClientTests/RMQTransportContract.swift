import XCTest

class RMQTransportContract {
    var transport: RMQTransport

    init(_ aTransport: RMQTransport) {
        transport = aTransport
    }
    
    func connectAndDisconnect() -> RMQTransportContract {
        try! transport.connect()
        transport.close()
        XCTAssert(TestHelper.pollUntil { return !self.transport.isConnected() }, "didn't disconnect")

        return self
    }
    
    func sendingPreambleStimulatesAConnectionStart() -> RMQTransportContract {
        defer { self.transport.close() }
        
        var readData: NSData = NSData()
        var connectionStart = RMQConnectionStart()

        try! self.transport.connect()
        self.transport.write(RMQProtocolHeader().amqEncoded())
        XCTAssertEqual(0, readData.length)
        self.transport.readFrame() { receivedData in
            readData = receivedData
            let parser = RMQParser(data: readData)
            let frame = RMQFrame(parser: parser)
            connectionStart = frame.payload as! RMQConnectionStart
        }

        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        XCTAssertEqual(RMQOctet(0), connectionStart.versionMajor)
        XCTAssertEqual(RMQOctet(9), connectionStart.versionMinor)

        return self
    }
}

