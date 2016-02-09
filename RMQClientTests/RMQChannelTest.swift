import XCTest

class RMQChannelTest: XCTestCase {
    
    func testClosedByDefault() {
        let ch = RMQChannel()
        XCTAssertFalse(ch.isOpen())
    }

    func testCanBeOpened() {
        let ch = RMQChannel()
        ch.open()
        XCTAssert(ch.isOpen())
    }

    func testCanBeClosed() {
        let ch = RMQChannel()
        ch.open().close()
        XCTAssertFalse(ch.isOpen())
    }

}
