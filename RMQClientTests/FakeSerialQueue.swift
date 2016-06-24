enum FakeSerialQueueError: ErrorType {
    case Overstep
}

@objc class FakeSerialQueue : NSObject, RMQLocalSerialQueue {
    var items: [() -> Void] = []
    var blockingItems: [() -> Void] = []
    var delayedItems: [() -> Void] = []
    var index = 0
    var suspended = false
    var enqueueDelay: NSNumber?

    func enqueue(operation: RMQOperation!) {
        items.append(operation)
    }

    func blockingEnqueue(operation: RMQOperation!) {
        items.append(operation)
        blockingItems.append(operation)
    }

    func delayedBy(delay: NSNumber!, enqueue operation: RMQOperation!) {
        items.append(operation)
        delayedItems.append(operation)
        enqueueDelay = delay
    }

    func suspend() {
        suspended = true
    }

    func resume() {
        suspended = false
    }

    // MARK: Helpers

    func step() throws {
        if index >= items.count {
            throw FakeSerialQueueError.Overstep
        }
        items[index]()
        index += 1
    }

    func finish() throws {
        while index < items.count {
            try step()
        }
    }

    func pendingItemsCount() -> Int {
        return items.count - index
    }
}
