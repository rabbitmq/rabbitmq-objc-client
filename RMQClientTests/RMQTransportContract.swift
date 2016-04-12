import XCTest

class RMQTransportContract {
    var transport: RMQTransport

    init(_ aTransport: RMQTransport) {
        transport = aTransport
    }
    
    func connectAndDisconnect() -> RMQTransportContract {
        try! transport.connect()
        var connected = true
        transport.close() {
            connected = false
        }
        XCTAssert(TestHelper.pollUntil { return !connected }, "didn't disconnect")

        return self
    }
    
    func sendingPreambleStimulatesAConnectionStart() -> RMQTransportContract {
        defer { self.transport.close() {} }
        
        var readData: NSData = NSData()
        var connectionStart = AMQConnectionStart()

        try! self.transport.connect()
        self.transport.write(AMQProtocolHeader().amqEncoded())
        XCTAssertEqual(0, readData.length)
        self.transport.readFrame() { receivedData in
            readData = receivedData
            let parser = AMQParser(data: readData)
            let frame = AMQFrame(parser: parser)
            connectionStart = frame.payload as! AMQConnectionStart
        }

        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        XCTAssertEqual(AMQOctet(0), connectionStart.versionMajor)
        XCTAssertEqual(AMQOctet(9), connectionStart.versionMinor)

        return self
    }
}

