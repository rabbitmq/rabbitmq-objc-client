import XCTest

class RMQGCDSerialQueueTest: XCTestCase {

    func testAsyncEnqueue() {
        let q = RMQGCDSerialQueue(name: "async enqueue test")
        let semaphore = dispatch_semaphore_create(0)
        q.enqueue() { dispatch_semaphore_signal(semaphore) }

        XCTAssertEqual(
            0,
            dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
            "Timed out waiting for queued work"
        )
    }

    func testSyncEnqueue() {
        let q = RMQGCDSerialQueue(name: "sync enqueue test")
        var foo = 1
        q.enqueue() { foo += 1 }
        q.blockingEnqueue { foo += 2 }

        XCTAssertEqual(4, foo)
    }

    func testSuspendAndResume() {
        let q = RMQGCDSerialQueue(name: "suspend and resume test")
        var foo = 1
        q.suspend()
        q.enqueue { foo += 1 }
        sleep(1)
        XCTAssertEqual(1, foo)
        q.resume()
        q.blockingEnqueue {}
        XCTAssertEqual(2, foo)
    }

}
