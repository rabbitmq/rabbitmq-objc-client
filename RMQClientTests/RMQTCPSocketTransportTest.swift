import XCTest

class RMQTCPSocketTransportTest: XCTestCase {
    
    func testOpenAndClose() {
        let transport = RMQTCPSocketTransport()
        
        XCTAssertFalse(transport.isOpen())
        transport.connect()

        while (!transport.isOpen()) {
            sleep(1)
        }
        XCTAssert(transport.isOpen())
        transport.close()
        XCTAssertFalse(transport.isOpen())
    }

}
