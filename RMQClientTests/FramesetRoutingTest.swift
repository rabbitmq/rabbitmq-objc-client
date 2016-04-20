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

        var consumerTriggered = false
        ch.basicConsume("foo", options: []) { message in
            consumerTriggered = true
        }

        allocator.handleFrameset(consumeOkFrameset)
        allocator.handleFrameset(deliverFrameset)

        XCTAssert(TestHelper.pollUntil { consumerTriggered }, "Timed out waiting for consumer frameset to be routed")
    }

}
