import XCTest

class RMQTransportContract {
    var transport: RMQTransport

    init(_ aTransport: RMQTransport) {
        transport = aTransport
    }
    
    func connectAndDisconnect() -> RMQTransportContract {
        var connected = false
        transport.connect() {
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

        return self
    }
    
    func sendingPreambleStimulatesAConnectionStart() -> RMQTransportContract {
        defer { self.transport.close() {} }
        
        var readData: NSData = NSData()
        var connectionStart = AMQProtocolConnectionStart()

        self.transport.connect() {
            try! self.transport.write(AMQProtocolHeader().amqEncoded()) {
                XCTAssertEqual(0, readData.length)
                self.transport.readFrame().then { receivedData in
                    readData = receivedData as! NSData
                    let decoder = AMQMethodDecoder(data: readData)
                    connectionStart = decoder.decode() as! AMQProtocolConnectionStart

                    let (promise, _, _) = Promise<NSData>.pendingPromise()
                    return AnyPromise(bound: promise)
                }
            }
        }

        XCTAssert(TestHelper.pollUntil { return readData.length > 0 }, "didn't read")
        XCTAssertEqual(AMQOctet(0), connectionStart.versionMajor)
        XCTAssertEqual(AMQOctet(9), connectionStart.versionMinor)

        return self
    }
}

