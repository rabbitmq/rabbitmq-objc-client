@objc class StarterSpy : NSObject, RMQStarter {
    var startCalled = false

    func start(completionHandler: (() -> Void)!) {
        startCalled = true
    }

    func start() {
        start {}
    }
}