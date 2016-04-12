import XCTest

class RMQFramesetSemaphoreWaiterTest: XCTestCase {
    
    func testTimeoutProducesError() {
        let waiter = RMQFramesetSemaphoreWaiter(syncTimeout: 0.1)
        let result = waiter.waitOn(AMQChannelOpenOk.self)

        XCTAssertNil(result.frameset)
        XCTAssertEqual(RMQChannelErrorWaitTimeout, result.error.code)
        XCTAssertEqual("Timed out waiting for AMQChannelOpenOk.", result.error.localizedDescription)
    }

    func testIncorrectFramesetProducesError() {
        let waiter = RMQFramesetSemaphoreWaiter(syncTimeout: 10)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        let deliveredFrameset = AMQFrameset(channelNumber: 1, method: MethodFixtures.basicConsumeOk("foo"))

        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            waiter.fulfill(deliveredFrameset)
        }
        let result = waiter.waitOn(AMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertEqual(RMQChannelErrorIncorrectSyncMethod, result.error.code)
        XCTAssertEqual("Expected AMQChannelOpenOk, got AMQBasicConsumeOk.", result.error.localizedDescription)
    }

    func testCorrectFramesetProducesFramesetAndNoError() {
        let waiter = RMQFramesetSemaphoreWaiter(syncTimeout: 10)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        let deliveredFrameset = AMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpenOk())

        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { 
            waiter.fulfill(deliveredFrameset)
        }
        let result = waiter.waitOn(AMQChannelOpenOk.self)

        XCTAssertEqual(deliveredFrameset, result.frameset)
        XCTAssertNil(result.error)
    }
    
}
