import XCTest

class RMQProcessInfoNameGeneratorTest: XCTestCase {

    func testGeneratesNamesWithProvidedPrefix() {
        let generator = RMQProcessInfoNameGenerator()
        let name1 = generator.generateWithPrefix("foo")
        let name2 = generator.generateWithPrefix("foo")

        XCTAssertEqual("foo", name1.substringToIndex(name1.startIndex.advancedBy(3)))
        XCTAssertEqual("foo", name2.substringToIndex(name2.startIndex.advancedBy(3)))
        XCTAssertNotEqual(name1, name2)
    }

}
