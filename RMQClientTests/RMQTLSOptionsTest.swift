import XCTest

class RMQTLSOptionsTest: XCTestCase {

    func testAuthMechanismIsPlainWhenNoPKCS12Provided() {
        let opts = RMQTLSOptions(peerName: "yokelboast",
                                 verifyPeer: true,
                                 pkcs12: nil,
                                 pkcs12Password: "foo")
        XCTAssertEqual("PLAIN", opts.authMechanism())
    }

    func testAuthMechanismIsExternalWhenPKCS12Provided() {
        let opts = RMQTLSOptions(peerName: "soakalmost",
                                 verifyPeer: true,
                                 pkcs12: CertificateFixtures.guestBunniesP12(),
                                 pkcs12Password: "bar")
        XCTAssertEqual("EXTERNAL", opts.authMechanism())
    }

    func testDelegatesCertificates() {
        let opts = RMQTLSOptions(peerName: "localghost",
                                 verifyPeer: true,
                                 pkcs12: CertificateFixtures.guestBunniesP12(),
                                 pkcs12Password: "bunnies")
        XCTAssertEqual(1, try! opts.certificates().count)
    }

    func testAmqpsUriIsParsedWithVerifyPeerEnabled() {
        let opts = RMQTLSOptions.fromURI("amqps://user:password@hosty.foo")
        XCTAssert(opts.useTLS)
        XCTAssertEqual("PLAIN", opts.authMechanism())
        XCTAssert(opts.verifyPeer)
        XCTAssertEqual("hosty.foo", opts.peerName)
    }

    func testAmqpsUriWithVerifyPeerDisabled() {
        let opts = RMQTLSOptions.fromURI("amqps://user:password@localhost", verifyPeer: false)
        XCTAssertFalse(opts.verifyPeer)
    }

    func testAmqpUriIsParsedAsNonTLS() {
        let opts = RMQTLSOptions.fromURI("amqp://user:password@hosty.foo")
        XCTAssertEqual("PLAIN", opts.authMechanism())
        XCTAssertFalse(opts.useTLS)
    }

    func testCanBeInstantiatedWithoutURI() {
        let opts = RMQTLSOptions(useTLS: true, peerName: "mypeer", verifyPeer: false, pkcs12: CertificateFixtures.guestBunniesP12(), pkcs12Password: "bunnies")
        XCTAssert(opts.useTLS)
        XCTAssertEqual("EXTERNAL", opts.authMechanism())
        XCTAssertFalse(opts.verifyPeer)
    }

    func testCanBeInstantiatedWithoutURIAndWithNilPKCS12() {
        let opts = RMQTLSOptions(useTLS: true, peerName: "mypeer", verifyPeer: true, pkcs12: nil, pkcs12Password: nil)
        XCTAssert(opts.useTLS)
        XCTAssertEqual("PLAIN", opts.authMechanism())
        XCTAssert(opts.verifyPeer)
    }

}
