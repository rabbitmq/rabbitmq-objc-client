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

    func sendMethod(amqMethod: AMQMethod, channelNumber: NSNumber) {
        lastSentMethod = amqMethod
    }

    func waitOnMethod(amqMethodClass: AnyClass, channelNumber: NSNumber) throws -> AMQFrameset {
        methodWaitedUpon = "\(amqMethodClass)"
        channelWaitedUpon = channelNumber
        return lastWaitedUponFrameset
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}