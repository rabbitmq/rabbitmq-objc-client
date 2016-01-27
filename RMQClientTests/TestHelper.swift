import Foundation

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

}