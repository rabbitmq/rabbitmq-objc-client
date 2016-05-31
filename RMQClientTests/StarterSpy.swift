@objc class StarterSpy : NSObject, RMQStarter {
    var startCompletionHandler: (() -> Void)?

    func start(completionHandler: (() -> Void)!) {
        startCompletionHandler = completionHandler
    }

    func start() {
        start {}
    }
}