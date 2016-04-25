@objc class FakeWaiter: NSObject, RMQWaiter {
    var doneCalled = false

    func done() {
        doneCalled = true
    }

    func timesOut() -> Bool {
        return false
    }
}