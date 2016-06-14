import XCTest

class RMQTransactionalConfirmationsTest: XCTestCase {

    func testAcksAndNacksArePassedToCallback() {
        let confirms = RMQTransactionalConfirmations()

        confirms.enable()
        for _ in 1...5 { confirms.addPublication() }

        var acks: Set<NSNumber> = []
        var nacks: Set<NSNumber> = []
        confirms.addCallback { (a, n) in
            acks = a
            nacks = n
        }

        confirms.ack(MethodFixtures.basicAck(1, options: []))
        XCTAssertEqual([], acks)
        XCTAssertEqual([], nacks)

        confirms.nack(MethodFixtures.basicNack(2, options: []))
        confirms.ack(MethodFixtures.basicAck(5, options: [.Multiple]))

        XCTAssertEqual([1, 3, 4, 5], acks)
        XCTAssertEqual([2], nacks)
    }

    func testAddingAPublicationHasNoEffectBeforeConfirmationsEnabled() {
        let confirms = RMQTransactionalConfirmations()

        confirms.addPublication()
        confirms.enable()
        confirms.addPublication()

        var acks: Set<NSNumber> = []
        confirms.addCallback { (a, _) in
            acks = a
        }

        confirms.ack(MethodFixtures.basicAck(1, options: []))

        XCTAssertEqual(1, acks.count)
    }

    func testEachCallbackReceivesAcksForPublicationsSinceLastCallbackSet() {
        let confirms = RMQTransactionalConfirmations()

        confirms.enable()
        confirms.addPublication() // 1
        confirms.addPublication() // 2

        var firstAcks: Set<NSNumber> = []
        var firstNacks: Set<NSNumber> = []
        confirms.addCallback { (a, n) in
            firstAcks = a
            firstNacks = n
        }

        confirms.addPublication() // 3
        confirms.addPublication() // 4

        var secondAcks: Set<NSNumber> = []
        var secondNacks: Set<NSNumber> = []
        confirms.addCallback { (a, n) in
            secondAcks = a
            secondNacks = n
        }

        confirms.ack(MethodFixtures.basicAck(1, options: []))          // ack 1
        confirms.nack(MethodFixtures.basicNack(3, options: []))        // nack 3
        confirms.ack(MethodFixtures.basicAck(4, options: [.Multiple])) // ack 2 and 4

        XCTAssertEqual([1, 2], firstAcks)
        XCTAssertEqual([], firstNacks)
        XCTAssertEqual([4], secondAcks)
        XCTAssertEqual([3], secondNacks)
    }

    // See this Bunny commit for an explanation:
    // https://github.com/ruby-amqp/bunny/commit/5e6d2b069cc17f44085e1778a0f6cad133a00dc1
    func testRecoveryIgnoresUnconfirmedTagsAndKeepsAnOffset() {
        let confirms = RMQTransactionalConfirmations()

        confirms.enable()
        for i in 1...4 {
            confirms.addPublication()
            confirms.ack(MethodFixtures.basicAck(UInt64(i), options: []))
        }

        for _ in 5...8 {
            confirms.addPublication() // these are never confirmed
        }

        confirms.recover()

        let expectedOffset = 8
        for i in 9...10 {
            confirms.addPublication()
            confirms.ack(MethodFixtures.basicAck(UInt64(i - expectedOffset), options: []))
        }

        for _ in 11...15 {
            confirms.addPublication()
        }
        confirms.nack(MethodFixtures.basicNack(7, options: [.Multiple]))

        var acks: Set<NSNumber>?
        var nacks: Set<NSNumber>?
        confirms.addCallback { (a, n) in
            acks = a
            nacks = n
        }

        XCTAssertEqual([1, 2, 3, 4, 9, 10], acks)
        XCTAssertEqual([11, 12, 13, 14, 15], nacks)
    }
}
