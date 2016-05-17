import XCTest

class RMQHTTPTest: XCTestCase {

    func testGet() {
        let http = RMQHTTP("http://httpbin.org")
        let actual = http.get("/get")
        let actualString = String(data: actual, encoding: NSUTF8StringEncoding)
        XCTAssertEqual("{\n  \"args\"", actualString?.substringToIndex(actualString!.startIndex.advancedBy(10)))
    }

    func testDelete() {
        let http = RMQHTTP("http://httpbin.org")
        let actual = http.delete("/delete")
        XCTAssertNotNil(NSString(data: actual, encoding: NSUTF8StringEncoding)?.rangeOfString("gzip, deflate"),
                        "Got: \(NSString(data: actual, encoding: NSUTF8StringEncoding))")
    }

}
