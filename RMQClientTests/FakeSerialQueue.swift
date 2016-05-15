enum FakeSerialQueueError: ErrorType {
    case Overstep
}

@objc class FakeSerialQueue : NSObject, RMQLocalSerialQueue {
    var items: [() -> Void] = []
    var blockingItems: [() -> Void] = []
    var index = 0
    var suspended = false

    func enqueue(operation: RMQOperation!) {
        items.append(operation)
    }

    func blockingEnqueue(operation: RMQOperation!) {
        items.append(operation)
        blockingItems.append(operation)
    }

    func suspend() {
        suspended = true
    }

    func resume() {
        suspended = false
    }

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
