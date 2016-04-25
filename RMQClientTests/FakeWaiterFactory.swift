@objc class FakeWaiterFactory: NSObject, RMQWaiterFactory {
    var waiters: [FakeWaiter] = []
    var framesetWaiters: [FramesetWaiterSpy] = []

    func makeWithTimeout(timeoutSeconds: NSNumber!) -> RMQWaiter! {
        let waiter = FakeWaiter()
        waiters.append(waiter)
        return waiter
    }
}