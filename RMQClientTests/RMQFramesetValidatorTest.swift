import XCTest

class RMQFramesetValidatorTest: XCTestCase {
    
    func testIncorrectFramesetProducesError() {
        let validator = RMQFramesetValidator()
        let deliveredFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("foo"))

        validator.fulfill(deliveredFrameset)
        let result = validator.expect(RMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, result.error.code)
        XCTAssertEqual("Expected RMQChannelOpenOk, got RMQBasicConsumeOk.", result.error.localizedDescription)
    }

    func testCorrectFramesetProducesFramesetAndNoError() {
        let validator = RMQFramesetValidator()
        let deliveredFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        validator.fulfill(deliveredFrameset)
        let result = validator.expect(RMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertNil(result.error)
    }
    
}
