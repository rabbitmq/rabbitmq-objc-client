import XCTest

class PublisherConfirmationIntegrationTest: XCTestCase {

    func testWaitingForConfirmations() {
        let semaphore = dispatch_semaphore_create(0)
        let conn = RMQConnection()
        conn.start()

        let ch = conn.createChannel()

        ch.confirmSelect()

        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        q.publish("message a")
        q.publish("message b")

        var acked: Set<NSNumber> = []
        var nacked: Set<NSNumber> = []

        ch.afterConfirmed { (acks, nacks) in
            acked = acks
            nacked = nacks
            dispatch_semaphore_signal(semaphore)
        }

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)))
        XCTAssertEqual([1, 2], acked)
        XCTAssertEqual([], nacked)
    }

}
