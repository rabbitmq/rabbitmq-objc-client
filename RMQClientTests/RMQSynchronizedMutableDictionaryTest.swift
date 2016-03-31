import XCTest

class RMQSynchronizedMutableDictionaryTest: XCTestCase {

    func testEqualToAnotherEmptyInstance() {
        XCTAssertEqual(RMQSynchronizedMutableDictionary(), RMQSynchronizedMutableDictionary())
    }

    func testEqualToAnotherInstanceWithSameKeysAndValues() {
        let a = RMQSynchronizedMutableDictionary()
        let b = RMQSynchronizedMutableDictionary()
        a[2] = "foo"
        b[2] = "foo"
        XCTAssertEqual(a, b)
    }

    func testNotEqualWithDifferentValues() {
        let a = RMQSynchronizedMutableDictionary()
        let b = RMQSynchronizedMutableDictionary()
        a[2] = "foo"
        b[2] = "bar"
        XCTAssertNotEqual(a, b)
    }

    func testSingleThreadedExample() {
        let sharedDictionary = RMQSynchronizedMutableDictionary()

        sharedDictionary[1] = "sandwich"
        sharedDictionary[2] = "prosciutto"
        sharedDictionary[3] = "pastrami"

        let actual1: String = sharedDictionary[1] as! String
        XCTAssertEqual("sandwich", actual1)
        let actual2: String = sharedDictionary[2] as! String
        XCTAssertEqual("prosciutto", actual2)
        let actual3: String = sharedDictionary[3] as! String
        XCTAssertEqual("pastrami", actual3)

        sharedDictionary.removeObjectForKey(2)

        XCTAssertNil(sharedDictionary[2])
    }

    func testMultiThreadedWritingExample() {
        let dictGroup = dispatch_group_create()

        let sharedDictionary = RMQSynchronizedMutableDictionary()
        var values: [String] = []

        for _ in 1...3000 {
            values.append(NSProcessInfo.processInfo().globallyUniqueString)
        }

        dispatch_group_async(dictGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            for n in 0...999 {
                sharedDictionary[n] = values[n]
            }
        }

        dispatch_group_async(dictGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            for n in 1000...1999 {
                sharedDictionary[n] = values[n]
            }
        }

        dispatch_group_async(dictGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            for n in 2000...2999 {
                sharedDictionary[n] = values[n]
            }
        }

        dispatch_group_wait(dictGroup, DISPATCH_TIME_FOREVER)

        for n in 0...2999 {
            let actual: String = sharedDictionary[n] as! String
            XCTAssertEqual(values[n], actual)
        }
    }

}
