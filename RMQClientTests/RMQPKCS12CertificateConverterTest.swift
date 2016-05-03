import XCTest

class RMQPKCS12CertificateConverterTest: XCTestCase {

    func testConvertNSDataToArrayOfCertificates() {
        let p12 = CertificateFixtures.guestBunniesP12()
        let converter = RMQPKCS12CertificateConverter(data: p12, password: "bunnies")
        let result = try! converter.certificates()

        XCTAssertEqual(1, result.count)
        let description = result.first!.description()
        XCTAssert(description.rangeOfString("SecIdentityRef") != nil,
                  "Didn't get SecIdentityRef as first item in cert array")
    }

    func testIncorrectPasswordThrowsError() {
        let p12 = CertificateFixtures.guestBunniesP12()
        let converter = RMQPKCS12CertificateConverter(data: p12, password: "hares")

        XCTAssertThrowsError(try converter.certificates()) { (error) in
            do {
                XCTAssertEqual(
                    RMQConnectionErrorTLSCertificateAuthFailure,
                    (error as NSError).code
                )
            }
        }
    }

    func testGarbageDataThrowsError() {
        let p12 = "somegarbage".dataUsingEncoding(NSUTF8StringEncoding)!
        let converter = RMQPKCS12CertificateConverter(data: p12, password: "bunnies")

        XCTAssertThrowsError(try converter.certificates()) { (error) in
            do {
                XCTAssertEqual(
                    RMQConnectionErrorTLSCertificateDecodeError,
                    (error as NSError).code
                )
            }
        }
    }

    func testReturnsEmptyCertificatesWhenNoP12DataProvided() {
        let converter = RMQPKCS12CertificateConverter(
            data: "".dataUsingEncoding(NSUTF8StringEncoding),
            password: "ez123"
        )
        XCTAssertEqual(0, try! converter.certificates().count)
    }

}
