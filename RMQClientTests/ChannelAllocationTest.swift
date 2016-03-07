import XCTest

class ChannelAllocationTest: XCTestCase {

    func allocateAll(allocator: RMQChannelAllocator, _ sender: RMQSender) {
        for _ in 1...AMQChannelLimit {
            allocator.allocateWithSender(sender)
        }
    }

    func testChannelGetsNegativeOneChannelNumberWhenOutOfChannelNumbers() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator()
        allocateAll(allocator, sender)
        XCTAssertEqual(-1, allocator.allocateWithSender(sender).channelID)
    }

    func testChannelGetsAFreedChannelNumberIfOtherwiseOutOfChannelNumbers() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator()
        allocateAll(allocator, sender)
        allocator.releaseChannelNumber(2)
        XCTAssertEqual(2, allocator.allocateWithSender(sender).channelID)
        XCTAssertEqual(-1, allocator.allocateWithSender(sender).channelID)
    }

    func testNumbersAreNotDoubleAllocated() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator()
        var channels1 = Set<NSNumber>()
        var channels2 = Set<NSNumber>()
        var channels3 = Set<NSNumber>()
        let queues = [
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        ]
        let group = dispatch_group_create()

        dispatch_group_async(group, queues[0]) {
            for _ in 1...30000 {
                channels1.insert(allocator.allocateWithSender(sender).channelID)
            }
        }

        dispatch_group_async(group, queues[1]) {
            for _ in 1...30000 {
                channels2.insert(allocator.allocateWithSender(sender).channelID)
            }
        }

        dispatch_group_async(group, queues[2]) {
            for _ in 1...30000 {
                channels3.insert(allocator.allocateWithSender(sender).channelID)
            }
        }

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)

        let expectedUniqueCannotAllocateCount = queues.count

        XCTAssertEqual(
            AMQChannelLimit + expectedUniqueCannotAllocateCount,
            channels1.count + channels2.count + channels3.count,
            "Got \(channels1.count), \(channels2.count) and \(channels3.count)"
        )
    }

}
