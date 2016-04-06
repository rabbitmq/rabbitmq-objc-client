import XCTest

class FramesetRoutingTest: XCTestCase {

    func testConsumerTriggeredWhenCorrectChannelAllocated() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator(sender: sender)

        let frameset = AMQFrameset(
            channelNumber: 1,
            method: MethodFixtures.basicDeliver(consumerTag: "atag4u", deliveryTag: 1)
        )

        allocator.allocate()          // 0
        let ch = allocator.allocate() // 1

        sender.lastWaitedUponFrameset = AMQFrameset(
            channelNumber: 1,
            method: AMQBasicConsumeOk(consumerTag: AMQShortstr("atag4u"))
        )
        var consumerTriggered = false
        try! ch.basicConsume("foo", options: []) { message in
            consumerTriggered = true
        }

        allocator.handleFrameset(frameset)

        XCTAssert(consumerTriggered)
    }

}
