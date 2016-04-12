class QueueHelper {
    var dispatchQueue: dispatch_queue_t
    var semaphore: dispatch_semaphore_t

    init() {
        dispatchQueue = dispatch_queue_create("com.rabbitmq.QueueHelperSerialQueue", nil)
        dispatch_suspend(dispatchQueue)
        semaphore = dispatch_semaphore_create(0)
    }

    func beforeExecution(block: () -> Void) -> Self {
        dispatch_async(dispatchQueue) { dispatch_semaphore_signal(self.semaphore) }
        block()
        return self
    }

    func afterExecution(block: () -> Void) -> Self {
        dispatch_resume(dispatchQueue)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        block()
        return self
    }
}