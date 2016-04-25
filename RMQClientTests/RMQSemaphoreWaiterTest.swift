import XCTest

class RMQSemaphoreWaiterTest: XCTestCase {

    func testCanTimeOut() {
        let waiter = RMQSemaphoreWaiter(timeout: 0)
        XCTAssert(waiter.timesOut())
    }

    func testCanBeFulfilledBeforeTimeOut() {
        let waiter = RMQSemaphoreWaiter(timeout: 2)
        waiter.done()
        XCTAssertFalse(waiter.timesOut())
    }

}
