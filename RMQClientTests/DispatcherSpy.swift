@objc class DispatcherSpy : NSObject, RMQDispatcher {
    var lastSyncMethod: RMQMethod?
    var lastSyncMethodHandler: (RMQFrameset! -> Void)?
    var lastBlockingSyncMethod: RMQMethod?
    var syncMethodsSent: [RMQMethod] = []
    var lastAsyncFrameset: RMQFrameset?
    var lastAsyncMethod: RMQMethod?
    var lastBlockingWaitOn: String?
    var activatedWithChannel: RMQChannel?
    var activatedWithDelegate: RMQConnectionDelegate?
    var lastFramesetHandled: RMQFrameset?
    var fakeSerialQueue = FakeSerialQueue()
    var disabled = false

    func blockingWaitOn(method: AnyClass!) {
        lastBlockingWaitOn = method.description()
    }

    func activateWithChannel(channel: RMQChannel!, delegate: RMQConnectionDelegate!) {
        activatedWithChannel = channel
        activatedWithDelegate = delegate
    }

    func sendAsyncMethod(method: RMQMethod!) {
        lastAsyncMethod = method
    }

    func sendAsyncFrameset(frameset: RMQFrameset!) {
        lastAsyncFrameset = frameset
    }

    func sendSyncMethod(method: RMQMethod!, completionHandler: (RMQFrameset! -> Void)) {
        syncMethodsSent.append(method)
        lastSyncMethod = method
        lastSyncMethodHandler = completionHandler
    }

    func sendSyncMethod(method: RMQMethod!) {
        sendSyncMethod(method) { _ in }
    }

    func sendSyncMethodBlocking(method: RMQMethod!) {
        syncMethodsSent.append(method)
        lastBlockingSyncMethod = method
    }

    func handleFrameset(frameset: RMQFrameset!) {
        lastFramesetHandled = frameset
    }

    func enqueue(operation: RMQOperation!) {
        fakeSerialQueue.enqueue(operation)
    }

    func disable() {
        disabled = true
        fakeSerialQueue.suspend()
    }

    func enable() {
        disabled = false
        fakeSerialQueue.resume()
    }

    // MARK: Helpers

    func step() throws {
        try fakeSerialQueue.step()
    }

    func finish() throws {
        try fakeSerialQueue.finish()
    }

    func pendingItemsCount() -> Int {
        return fakeSerialQueue.pendingItemsCount()
    }

}