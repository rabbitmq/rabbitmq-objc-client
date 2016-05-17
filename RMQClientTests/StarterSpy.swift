@objc class StarterSpy : NSObject, RMQStarter {
    var startCalled = false

    func start() {
        startCalled = true
    }
}