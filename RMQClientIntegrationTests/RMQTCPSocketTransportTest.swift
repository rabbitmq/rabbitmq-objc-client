import XCTest

class RMQTCPSocketTransportTest: XCTestCase {
    
    func pollUntil(checker: () -> Bool) {
        for _ in 1...10 {
            if checker() {
                return
            } else {
                NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.5))
            }
        }
        XCTFail("polling timed out")
    }
    
    func testConnectAndDisconnect() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        XCTAssertFalse(transport.isConnected())
        transport.connect()
        pollUntil { transport.isConnected() }
        transport.close()
        pollUntil { !transport.isConnected() }
    }
    
    func testSendPreambleReceiveConnectionStart() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        transport.connect()
        defer { transport.close() }
        
        pollUntil { transport.isConnected() }
        
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        
        transport.write(data)
        
        // TODO: check something
    }

}
