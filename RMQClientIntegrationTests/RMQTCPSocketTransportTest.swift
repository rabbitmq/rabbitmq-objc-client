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
        
        XCTAssertFalse(transport.isConnected())
    }

    func testCallbacksAreRemovedAfterUse() {
        let callbacks = [:] as NSMutableDictionary
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672, callbackStorage: callbacks)

        var finished = false
        transport.connect {
            try! transport.write(AMQProtocolHeader().amqEncoded()) {
                transport.readFrame({ (foo) -> Void in
                    transport.close { finished = true }
                })
            }
        }

        XCTAssert(TestHelper.pollUntil { return finished }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }
}
