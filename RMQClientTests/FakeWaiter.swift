@objc class FakeWaiter: NSObject, RMQWaiter {
    var doneCalled = false
    var timesOutCalled = false

    func done() {
        doneCalled = true
    }

    func timesOut() -> Bool {
        timesOutCalled = true
        return false
    }
}