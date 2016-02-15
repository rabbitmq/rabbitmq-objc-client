import Foundation
import XCTest

class TestHelper {

    static func pollUntil(checker: () -> Bool) -> Bool {
        for _ in 1...10 {
            if checker() {
                return true
            } else {
                run(0.5)
            }
        }
        return false
    }

    static func run(time: NSTimeInterval) {
        NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(time))
    }

    static func assertEqualBytes(expected: NSData, _ actual: NSData, _ message: String = "") {
        if message == "" {
            XCTAssertEqual(expected, actual, "\n\nBytes not equal:\n\(expected)\n\(actual)")
        } else {
            XCTAssertEqual(expected, actual, message)
        }
    }
}