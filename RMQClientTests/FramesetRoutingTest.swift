import XCTest

class FramesetRoutingTest: XCTestCase {

    func testConsumerTriggeredWhenCorrectChannelAllocated() {
        let allocator = RMQMultipleChannelAllocator(sender: SenderSpy())

        let frameset = AMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.queueDeclare("foo"),
            contentHeader: AMQContentHeaderNone(),
            contentBodies: []
        )

        allocator.allocate()          // 0
        let ch = allocator.allocate() // 1

        var consumerTriggered = false
        ch.basicConsume("foo") { message in
            consumerTriggered = true
        }

        allocator.handleFrameset(frameset)

        XCTAssert(consumerTriggered)
    }

}
