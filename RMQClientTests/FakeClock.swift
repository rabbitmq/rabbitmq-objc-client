@objc class FakeClock: NSObject, RMQClock {
    var date = NSDate()

    func read() -> NSDate! {
        return date
    }

    func advance(interval: NSTimeInterval) {
        date = date.dateByAddingTimeInterval(interval)
    }
}