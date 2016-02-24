@objc class FakeFrameHandler : NSObject, RMQFrameHandler {
    var receivedFramesets: [AMQFrameset] = []

    func handleFrameset(frameset: AMQFrameset!) {
        receivedFramesets.append(frameset)
    }

    func lastReceivedFrameset() -> AMQFrameset? {
        return receivedFramesets.last
    }
}