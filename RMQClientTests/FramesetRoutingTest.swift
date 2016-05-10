import XCTest

class FramesetRoutingTest: XCTestCase {

    func testConsumerTriggeredWhenCorrectChannelAllocated() {
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)

        let consumeOkFrameset = RMQFrameset(
            channelNumber: 1,
            method: RMQBasicConsumeOk(consumerTag: RMQShortstr("atag4u"))
        )
        let deliverFrameset = RMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicDeliver(consumerTag: "atag4u", deliveryTag: 1)
        )

        allocator.allocate()          // 0
        let ch = allocator.allocate() // 1

        ch.activateWithDelegate(nil)

        let semaphore = dispatch_semaphore_create(0)
        ch.basicConsume("foo", options: []) { (_, _) in
            dispatch_semaphore_signal(semaphore)
        }

        TestHelper.run(0.5)

        allocator.handleFrameset(consumeOkFrameset)
        allocator.handleFrameset(deliverFrameset)

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for consumer frameset to be routed")
    }

}
