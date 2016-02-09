import XCTest

class RMQChannelTest: XCTestCase {
    
    func testClosedByDefault() {
        let ch = RMQChannel(0)
        XCTAssertFalse(ch.isOpen())
    }

    func testCanBeOpened() {
        let ch = RMQChannel(0)
        ch.open()
        XCTAssert(ch.isOpen())
    }

    func testCanBeClosed() {
        let ch = RMQChannel(0)
        ch.open().close()
        XCTAssertFalse(ch.isOpen())
    }

}
