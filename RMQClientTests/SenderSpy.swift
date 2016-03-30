@objc class NothingSentYet : AMQFrameset {}

@objc class SenderSpy : NSObject, RMQSender {
    var lastWaitedUponFrameset: AMQFrameset = AMQFrameset()
    var sentFramesets: [AMQFrameset] = []
    var lastSentMethod: AMQMethod?
    var methodWaitedUpon: String = "nothing waited upon yet!"
    var channelWaitedUpon: NSNumber = -1
    var frameMax: NSNumber

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func sendFrameset(frameset: AMQFrameset) {
        sentFramesets.append(frameset)
    }

    func sendFrameset(frameset: AMQFrameset, waitOnMethod amqMethodClass: AnyClass) throws -> AMQFrameset {
        sentFramesets.append(frameset)
        lastSentMethod = frameset.method
        methodWaitedUpon = "\(amqMethodClass)"
        channelWaitedUpon = frameset.channelNumber
        return lastWaitedUponFrameset
    }

    func sendMethod(amqMethod: AMQMethod, channelNumber: NSNumber) {
        lastSentMethod = amqMethod
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}