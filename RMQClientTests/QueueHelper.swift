class QueueHelper {
    let dispatchQueue: RMQGCDSerialQueue

    init() {
        dispatchQueue = RMQGCDSerialQueue()
        dispatchQueue.suspend()
    }

    deinit {
        resume()
    }

    func resume() -> Self {
        dispatchQueue.resume()
        return self
    }

    func suspend() -> Self {
        dispatchQueue.suspend()
        return self
    }

    func finish() -> Self {
        resume()
        dispatchQueue.blockingEnqueue {}
        suspend()
        return self
    }
}