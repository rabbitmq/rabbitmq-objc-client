import XCTest

class RMQTCPSocketTransportTest: XCTestCase {
    
    func testOpenAndClose() {
        if NSProcessInfo.processInfo().environment["CI"] != nil {
            return
        }
        
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

}
