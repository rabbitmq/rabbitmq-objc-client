@objc class DispatcherSpy : NSObject, RMQDispatcher {
    var lastSyncMethod: RMQMethod?
    var lastSyncWaitedOn: String?
    var lastSyncMethodHandler: (RMQFramesetValidationResult! -> Void)?
    var lastBlockingSyncMethod: RMQMethod?
    var lastBlockingSyncWaitedOn: String?
    var syncMethodsSent: [RMQMethod] = []
    var lastAsyncFrameset: RMQFrameset?
    var lastAsyncMethod: RMQMethod?
    var lastBlockingWaitOn: String?
    var activatedWithChannel: RMQChannel?
    var activatedWithDelegate: RMQConnectionDelegate?
    var lastFramesetHandled: RMQFrameset?

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

    func sendSyncMethod(method: RMQMethod!, waitOn: AnyClass!, completionHandler: (RMQFramesetValidationResult! -> Void)) {
        syncMethodsSent.append(method)
        lastSyncMethod = method
        lastSyncWaitedOn = waitOn.description()
        lastSyncMethodHandler = completionHandler
    }

    func sendSyncMethod(method: RMQMethod!, waitOn: AnyClass!) {
        sendSyncMethod(method, waitOn: waitOn) { _ in }
    }

    func sendSyncMethodBlocking(method: RMQMethod!, waitOn: AnyClass!) {
        syncMethodsSent.append(method)
        lastBlockingSyncMethod = method
        lastBlockingSyncWaitedOn = waitOn.description()
    }

    func handleFrameset(frameset: RMQFrameset!) {
        lastFramesetHandled = frameset
    }

}