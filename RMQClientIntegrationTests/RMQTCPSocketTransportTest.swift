import XCTest
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: XCTestCase {
    static let noTLS = RMQTLSOptions.fromURI("amqp://localhost")
    let noTLS = RMQTLSOptions.fromURI("amqp://localhost")

    func testObeysContract() {
        RMQTransportContract(createTransport()).check()
    }

    func testIsNotConnectedWhenSocketDisconnectedOutsideOfCloseBlock() {
        let transport = createTransport()
        let error = NSError(domain: "", code: 0, userInfo: [:])
        transport.socketDidDisconnect(GCDAsyncSocket(), withError: error)
        
        XCTAssertFalse(transport.isConnected())
    }

    func testCallbacksAreRemovedAfterUse() {
        let callbacks = [:] as NSMutableDictionary
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks)

        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "couldn't connect")

        transport.write(RMQProtocolHeader().amqEncoded())
        transport.readFrame { _ in
            transport.close()
        }

        XCTAssert(TestHelper.pollUntil { return !transport.isConnected() }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }

    func testSendsErrorToDelegateWhenConnectionTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        let delegate = TransportDelegateSpy()
        let transport = RMQTCPSocketTransport(host: "localhost", port: 123456,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks)

        transport.delegate = delegate
        try! transport.connect()

        TestHelper.pollUntil { delegate.lastDisconnectError != nil }

        XCTAssertEqual("Connection refused", delegate.lastDisconnectError?.localizedDescription)
    }

    func testExtendsReadWhenReadTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        let transport = RMQTCPSocketTransport(host: "localhost", port: 123456,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks)
        let timeoutExtension = transport.socket(GCDAsyncSocket(), shouldTimeoutReadWithTag: 123, elapsed: 123, bytesDone: 999)
        XCTAssert(timeoutExtension > 0)
    }

    func testConnectsViaTLS() {
        let semaphore = dispatch_semaphore_create(0)
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5671,
                                              tlsOptions: RMQTLSOptions(peerName: "localhost", verifyPeer: false, pkcs12: nil, pkcs12Password: ""))
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

    func testConnectsViaTLSWithClientCert() {
        let semaphore = dispatch_semaphore_create(0)
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: CertificateFixtures.guestBunniesP12(),
            pkcs12Password: "bunnies"
        )
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5671, tlsOptions: tlsOptions)
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

    func testThrowsWhenTLSPasswordIncorrect() {
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: CertificateFixtures.guestBunniesP12(),
            pkcs12Password: "incorrect-password"
        )
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5671, tlsOptions: tlsOptions)
        XCTAssertThrowsError(try transport.connect())
    }

    func testSimulatedDisconnectCausesTransportToReportAsDisconnected() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672, tlsOptions: noTLS)
        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { transport.isConnected() })
        transport.simulateDisconnect()
        XCTAssert(TestHelper.pollUntil { !transport.isConnected() })
    }

    func testSimulatedDisconnectSendsErrorToDelegate() {
        let transport = RMQTCPSocketTransport(host: "localhost", port: 5672, tlsOptions: noTLS)
        let delegate = TransportDelegateSpy()
        transport.delegate = delegate
        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { transport.isConnected() })
        transport.write(RMQProtocolHeader().amqEncoded())
        transport.simulateDisconnect()

        // CocoaAsyncSocket doesn't send an error object at time of writing
        XCTAssert(TestHelper.pollUntil { delegate.disconnectCalled })
    }

    func createTransport() -> RMQTCPSocketTransport {
        return RMQTCPSocketTransport(host: "localhost",
                                     port: 5672,
                                     tlsOptions: noTLS)
    }

}
