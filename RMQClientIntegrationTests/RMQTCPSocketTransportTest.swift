import XCTest

class RMQTCPSocketTransportTest: XCTestCase {
    
    func testOpenAndClose() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        XCTAssertFalse(transport.isOpen())
        transport.connect()
        
        for _ in 1...10 {
            if transport.isOpen() {
                break
            }
            sleep(1)
        }
        XCTAssert(transport.isOpen())
        
        transport.close()
        XCTAssertFalse(transport.isOpen())
    }
    
    func testSendPreambleReceiveConnectionStart() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672)
        
        transport.connect()
        defer { transport.close() }
        
        for _ in 1...10 {
            if transport.isOpen() {
                break
            }
            sleep(1)
        }
        XCTAssert(transport.isOpen())
        
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        
        transport.write(data)
        
        transport.read()
    }

}
