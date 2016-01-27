import Foundation
import XCTest

class TestHelper {

    static func pollUntil(checker: () -> Bool) -> Bool {
        for _ in 1...10 {
            if checker() {
                return true
            } else {
                NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.5))
            }
        }
        return false
    }
    
    static func assertEqualBytes(expected: NSData, actual: NSData) {
        XCTAssertEqual(expected, actual, "Bytes not equal:\n\(expected)\n\(actual)")
    }

}