import XCTest

class FakeSerialQueueTest: XCTestCase {

    func testCanStepThroughItemsSentAsync() {
        let q = FakeSerialQueue()
        var i = 0
        q.enqueue { i += 1 }
        q.enqueue { i += 2 }
        XCTAssertEqual(0, i)
        try! q.step()
        XCTAssertEqual(1, i)
        try! q.step()
        XCTAssertEqual(3, i)

        XCTAssertThrowsError(try q.step())
    }

}
