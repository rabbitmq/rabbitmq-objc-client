@objc class NothingSentYet : AMQFrameset {}

@objc class SenderSpy : NSObject, RMQSender {
    var lastWaitedUponFrameset: AMQFrameset = AMQFrameset()
    var lastSentFrameset: AMQFrameset = NothingSentYet()
    var lastSentMethod: AMQMethod?
    var methodWaitedUpon: String = "nothing waited upon yet!"
    var channelWaitedUpon: NSNumber = -1
    var frameMax: NSNumber

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func send(encodable: AMQEncoding) {
        lastSentFrameset = encodable as! AMQFrameset
    }

    func sendMethod(amqMethod: AMQMethod, channelNumber: NSNumber) {
        lastSentMethod = amqMethod
    }

    func waitOnMethod(amqMethodClass: AnyClass, channelNumber: NSNumber) throws {
        methodWaitedUpon = "\(amqMethodClass)"
        channelWaitedUpon = channelNumber
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}