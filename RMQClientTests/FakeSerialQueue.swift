enum FakeSerialQueueError: ErrorType {
    case Overstep
}

@objc class FakeSerialQueue : NSObject, RMQLocalSerialQueue {
    var items: [() -> Void] = []
    var blockingItems: [() -> Void] = []
    var index = 0
    var suspended = false

    func enqueue(operation: (() -> Void)!) {
        items.append(operation)
    }

    func blockingEnqueue(operation: (() -> Void)!) {
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
}
