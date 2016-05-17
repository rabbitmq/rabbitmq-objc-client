@objc class HeartbeatSenderSpy: NSObject, RMQHeartbeatSender {
    var heartbeatIntervalReceived: NSNumber?
    var stopReceived = false
    var signalActivityReceived = false

    func startWithInterval(intervalSeconds: NSNumber!) -> (() -> Void)! {
        heartbeatIntervalReceived = intervalSeconds
        return {}
    }

    func stop() {
        stopReceived = true
    }

    func signalActivity() {
        signalActivityReceived = true
    }
}