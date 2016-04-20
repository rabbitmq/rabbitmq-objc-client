import XCTest
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: XCTestCase {
    var transport: RMQTCPSocketTransport = RMQTCPSocketTransport(host: "localhost", port: 5672)

    func testObeysContract() {
        RMQTransportContract(transport)
            .connectAndDisconnect()
            .sendingPreambleStimulatesAConnectionStart()
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
        try! transport.connect()
        transport.write(RMQProtocolHeader().amqEncoded())
        transport.readFrame { _ in
            self.transport.close { finished = true }
        }

        XCTAssert(TestHelper.pollUntil { return finished }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }

    func testSendsErrorToDelegateWhenConnectionTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        let delegate = TransportDelegateSpy()
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456, callbackStorage: callbacks)

        transport.delegate = delegate
        try! transport.connect()

        TestHelper.pollUntil { delegate.lastDisconnectError.localizedDescription != "no error yet" }

        XCTAssertEqual("Connection refused", delegate.lastDisconnectError.localizedDescription)
    }

    func testExtendsReadWhenReadTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456, callbackStorage: callbacks)
        let timeoutExtension = transport.socket(GCDAsyncSocket(), shouldTimeoutReadWithTag: 123, elapsed: 123, bytesDone: 999)
        XCTAssert(timeoutExtension > 0)
    }
}
