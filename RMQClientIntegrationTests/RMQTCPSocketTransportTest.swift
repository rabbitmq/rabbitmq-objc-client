import XCTest
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: XCTestCase {
    var transport: RMQTCPSocketTransport = RMQTCPSocketTransport(host: "localhost", port: 5672)

    func testObeysContract() {
        RMQTransportContract(transport)
            .connectAndDisconnect()
            .throwsWhenWritingButNotConnected()
            .sendingPreambleStimulatesAConnectionStart()
    }

    func testConnectBlocksUntilConnectBlockCalled() {
        let timeBefore = NSDate()
        transport.connect {
            usleep(200000)
        }
        let elapsed = NSDate().timeIntervalSinceDate(timeBefore)
        XCTAssert(elapsed > 0.2)
    }

    func testIsNotConnectedWhenSocketDisconnectedOutsideOfCloseBlock() {
        let error = NSError(domain: "", code: 0, userInfo: [:])
        transport.socketDidDisconnect(GCDAsyncSocket(), withError: error)
        
        XCTAssertFalse(transport.isConnected())
    }

    func testCallbacksAreRemovedAfterUse() {
        let callbacks = [:] as NSMutableDictionary
        transport = RMQTCPSocketTransport(host: "localhost", port: 5672, callbackStorage: callbacks)

        var finished = false
        transport.connect {
            try! transport.write(AMQProtocolHeader().amqEncoded()) {
                transport.readFrame { _ in
                    transport.close { finished = true }
                }
            }
        }

        XCTAssert(TestHelper.pollUntil { return finished }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }
}
