class QueueHelper {
    let dispatchQueue: dispatch_queue_t

    init() {
        dispatchQueue = dispatch_queue_create("QueueHelperSerialQueue", nil)
        dispatch_suspend(dispatchQueue)
    }

    deinit {
        resume()
    }

    func resume() -> Self {
        dispatch_resume(dispatchQueue)
        return self
    }

    func suspend() -> Self {
        dispatch_suspend(dispatchQueue)
        return self
    }

    func finish() -> Self {
        resume()
        dispatch_sync(dispatchQueue) {}
        suspend()
        return self
    }
}