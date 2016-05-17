import XCTest

class FramesetRoutingTest: XCTestCase {

    func testConsumerTriggeredWhenCorrectChannelAllocated() {
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)

        allocator.allocate()          // 0
        let ch = allocator.allocate() // 1

        ch.activateWithDelegate(nil)

        let semaphore = dispatch_semaphore_create(0)
        let consumer = ch.basicConsume("foo", options: []) { (_, _) in
            dispatch_semaphore_signal(semaphore)
        }

        TestHelper.run(0.5)

        let consumeOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicConsumeOk(consumer.tag)
        )
        let deliverFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicDeliver(consumerTag: consumer.tag, deliveryTag: 1)
        )

        allocator.handleFrameset(consumeOkFrameset)
        allocator.handleFrameset(deliverFrameset)

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for consumer frameset to be routed")
    }

}
