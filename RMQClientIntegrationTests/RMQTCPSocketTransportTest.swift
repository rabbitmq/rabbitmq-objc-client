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
        try! transport.connect {
            usleep(200000)
        }
        let elapsed = NSDate().timeIntervalSinceDate(timeBefore)
        XCTAssert(elapsed > 0.2, "Expected \(elapsed) to be > 0.2")
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
        try! transport.connect {
            try! self.transport.write(AMQProtocolHeader().amqEncoded()) {
                self.transport.readFrame { _ in
                    self.transport.close { finished = true }
                }
            }
        }

        XCTAssert(TestHelper.pollUntil { return finished }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }

    func testPropagatesErrorWhenConnectionTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456, callbackStorage: callbacks)
        do {
            try transport.connect {}
        }
        catch let e as NSError {
            XCTAssertEqual("Timed out waiting to connect", e.localizedDescription)
        }
        catch {
            XCTFail("Should have failed on timeout")
        }
    }

    func testExtendsReadWhenReadTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456, callbackStorage: callbacks)
        let timeoutExtension = transport.socket(GCDAsyncSocket(), shouldTimeoutReadWithTag: 123, elapsed: 123, bytesDone: 999)
        XCTAssert(timeoutExtension > 0)
    }
}
