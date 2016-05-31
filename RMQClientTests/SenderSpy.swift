@objc class SenderSpy : NSObject, RMQSender {
    var sentFramesets: [RMQFrameset] = []
    var lastSentMethod: RMQMethod?
    var frameMax: NSNumber

    init(frameMax aFrameMax: UInt = RMQFrameMax) {
        frameMax = aFrameMax
    }

    func sendFrameset(frameset: RMQFrameset, force isForced: Bool) {
        lastSentMethod = frameset.method
        sentFramesets.append(frameset)
    }

    func sendFrameset(frameset: RMQFrameset) {
        sendFrameset(frameset, force: false)
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}