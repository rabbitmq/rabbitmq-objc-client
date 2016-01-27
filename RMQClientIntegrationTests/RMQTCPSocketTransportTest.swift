import XCTest
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: RMQTransportContract {
    override func newTransport() -> RMQTransport {
        return RMQTCPSocketTransport(host: "localhost", port: 5672)
    }
    
    func testIsNotConnectedWhenSocketDisconnectedOutsideOfCloseBlock() {
        let transport: RMQTCPSocketTransport = newTransport() as! RMQTCPSocketTransport
        let error = NSError(domain: "", code: 0, userInfo: [:])
        transport.socketDidDisconnect(GCDAsyncSocket(), withError: error)
        
        XCTAssertFalse(transport.isConnected());
    }
}
