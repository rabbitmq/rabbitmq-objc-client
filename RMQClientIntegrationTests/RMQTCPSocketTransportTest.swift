import XCTest
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: XCTestCase {
    var transport: RMQTCPSocketTransport = RMQTCPSocketTransport(host: "localhost", port: 5672,
                                                                 tlsOptions: RMQTLSOptions(useTLS: false, peerName: "foo", verifyPeer: false))

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
        transport = RMQTCPSocketTransport(host: "localhost", port: 5672,
                                          tlsOptions: RMQTLSOptions(useTLS: false, peerName: "foo", verifyPeer: false),
                                          callbackStorage: callbacks)

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
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456,
                                          tlsOptions: RMQTLSOptions(useTLS: false, peerName: "foo", verifyPeer: false),
                                          callbackStorage: callbacks)

        transport.delegate = delegate
        try! transport.connect()

        TestHelper.pollUntil { delegate.lastDisconnectError.localizedDescription != "no error yet" }

        XCTAssertEqual("Connection refused", delegate.lastDisconnectError.localizedDescription)
    }

    func testExtendsReadWhenReadTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        transport = RMQTCPSocketTransport(host: "localhost", port: 123456,
                                          tlsOptions: RMQTLSOptions(useTLS: false, peerName: "foo", verifyPeer: false),
                                          callbackStorage: callbacks)
        let timeoutExtension = transport.socket(GCDAsyncSocket(), shouldTimeoutReadWithTag: 123, elapsed: 123, bytesDone: 999)
        XCTAssert(timeoutExtension > 0)
    }

    func testConnectsViaTLS() {
        let semaphore = dispatch_semaphore_create(0)
        transport = RMQTCPSocketTransport(host: "localhost", port: 5671,
                                          tlsOptions: RMQTLSOptions(useTLS: true, peerName: "localhost", verifyPeer: false))
        try! transport.connect()
        transport.write(RMQProtocolHeader().amqEncoded())

        var receivedData: NSData?
        transport.readFrame { data in
            receivedData = data
            dispatch_semaphore_signal(semaphore)
        }

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(2)),
                       "Timed out waiting for read")
        let parser = RMQParser(data: receivedData!)
        XCTAssert(RMQFrame(parser: parser).payload.isKindOfClass(RMQConnectionStart))
    }

}
