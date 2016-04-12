@objc class SenderSpy : NSObject, RMQSender {
    var sentFramesets: [AMQFrameset] = []
    var lastSentMethod: AMQMethod?
    var frameMax: NSNumber

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func sendFrameset(frameset: AMQFrameset) {
        lastSentMethod = frameset.method
        sentFramesets.append(frameset)
    }

    func sendMethod(amqMethod: AMQMethod, channelNumber: NSNumber) {
        lastSentMethod = amqMethod
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}