import XCTest

class RMQTLSOptionsTest: XCTestCase {

    func testNoTLS() {
        let opts = RMQTLSOptions.noTLS()
        XCTAssertFalse(opts.useTLS)
    }

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

}
