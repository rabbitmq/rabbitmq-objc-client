@objc class FrameHandlerSpy : NSObject, RMQFrameHandler {
    var receivedFramesets: [RMQFrameset] = []

    func handleFrameset(frameset: RMQFrameset!) {
        receivedFramesets.append(frameset)
    }

    func lastReceivedFrameset() -> RMQFrameset? {
        return receivedFramesets.last
    }
}