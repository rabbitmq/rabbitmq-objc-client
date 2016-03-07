import XCTest

class ChannelAllocationTest: XCTestCase {
    let allocationsPerQueue = 30000

    func allocateAll(allocator: RMQChannelAllocator, _ sender: RMQSender) {
        for _ in 1...AMQChannelLimit {
            allocator.allocateWithSender(sender)
        }
    }

    func testChannelGetsNegativeOneChannelNumberWhenOutOfChannelNumbers() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator()
        allocateAll(allocator, sender)
        XCTAssertEqual(-1, allocator.allocateWithSender(sender).channelNumber)
    }

    func testChannelGetsAFreedChannelNumberIfOtherwiseOutOfChannelNumbers() {
        let sender = SenderSpy()
        let allocator = RMQMultipleChannelAllocator()
        allocateAll(allocator, sender)
        allocator.releaseChannelNumber(2)
        XCTAssertEqual(2, allocator.allocateWithSender(sender).channelNumber)
        XCTAssertEqual(-1, allocator.allocateWithSender(sender).channelNumber)
    }

    func testNumbersAreNotDoubleAllocated() {
        let sender      = SenderSpy()
        let allocator   = RMQMultipleChannelAllocator()
        var channelSet1 = Set<NSNumber>()
        var channelSet2 = Set<NSNumber>()
        var channelSet3 = Set<NSNumber>()
        let group       = dispatch_group_create()
        let queues      = [
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        ]

        dispatch_group_async(group, queues[0]) {
            for _ in 1...self.allocationsPerQueue {
                channelSet1.insert(allocator.allocateWithSender(sender).channelNumber)
            }
        }

        dispatch_group_async(group, queues[1]) {
            for _ in 1...self.allocationsPerQueue {
                channelSet2.insert(allocator.allocateWithSender(sender).channelNumber)
            }
        }

        dispatch_group_async(group, queues[2]) {
            for _ in 1...self.allocationsPerQueue {
                channelSet3.insert(allocator.allocateWithSender(sender).channelNumber)
            }
        }

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)

        let channelSets                    = [channelSet1, channelSet2, channelSet3]
        let expectedUniqueUnallocatedCount = channelSets.reduce(0, combine: sumUnallocated)
        let total                          = channelSets.reduce(0, combine: {$0 + $1.count})

        XCTAssertEqual(AMQChannelLimit + expectedUniqueUnallocatedCount, total)
    }

    func sumUnallocated(accumulator: Int, current: Set<NSNumber>) -> Int {
        return accumulator + (current.count == self.allocationsPerQueue ? 0 : 1)
    }

}
