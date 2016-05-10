import XCTest

class RMQFramesetSemaphoreWaiterTest: XCTestCase {
    
    func testIncorrectFramesetProducesError() {
        let waiter = RMQFramesetSemaphoreWaiter()
        let deliveredFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("foo"))

        waiter.fulfill(deliveredFrameset)
        let result = waiter.waitOn(RMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertEqual(RMQError.ChannelIncorrectSyncMethod.rawValue, result.error.code)
        XCTAssertEqual("Expected RMQChannelOpenOk, got RMQBasicConsumeOk.", result.error.localizedDescription)
    }

    func testCorrectFramesetProducesFramesetAndNoError() {
        let waiter = RMQFramesetSemaphoreWaiter()
        let deliveredFrameset = RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        waiter.fulfill(deliveredFrameset)
        let result = waiter.waitOn(RMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertNil(result.error)
    }
    
}
