@objc class FakeWaiterFactory: NSObject, RMQWaiterFactory {
    var waiters: [FakeWaiter] = []

    func makeWithTimeout(timeoutSeconds: NSNumber!) -> RMQWaiter! {
        let waiter = FakeWaiter()
        waiters.append(waiter)
        return waiter
    }
}