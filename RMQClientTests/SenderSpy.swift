@objc class SenderSpy : NSObject, RMQSender {
    var sentFramesets: [RMQFrameset] = []
    var lastSentMethod: RMQMethod?
    var frameMax: NSNumber

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func sendFrameset(frameset: RMQFrameset) {
        lastSentMethod = frameset.method
        sentFramesets.append(frameset)
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}