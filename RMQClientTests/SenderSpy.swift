enum SenderSpyError: ErrorType {
    case ArbitraryError(localizedDescription: String)
}

@objc class NothingSentYet : AMQFrameset {}

@objc class SenderSpy : NSObject, RMQSender {
    var lastWaitedUponFrameset: AMQFrameset = AMQFrameset()
    var sentFramesets: [AMQFrameset] = []
    var lastSentMethod: AMQMethod?
    var methodWaitedUpon: String = "nothing waited upon yet!"
    var channelWaitedUpon: NSNumber = -1
    var frameMax: NSNumber
    var throwFromSendFramesetWaitUpon = false

    static func waitingUpon(method: AMQMethod, channelNumber: Int) -> SenderSpy {
        let sender = SenderSpy()
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: channelNumber, method: method)
        return sender
    }

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func sendFrameset(frameset: AMQFrameset) {
        sentFramesets.append(frameset)
    }

    func sendFrameset(frameset: AMQFrameset, waitOnMethod amqMethodClass: AnyClass) throws -> AMQFrameset {
        if throwFromSendFramesetWaitUpon {
            throw SenderSpyError.ArbitraryError(localizedDescription: "stubbed to throw")
        } else {
            sentFramesets.append(frameset)
            lastSentMethod = frameset.method
            methodWaitedUpon = "\(amqMethodClass)"
            channelWaitedUpon = frameset.channelNumber
            return lastWaitedUponFrameset
        }
    }

    func sendMethod(amqMethod: AMQMethod, channelNumber: NSNumber) {
        lastSentMethod = amqMethod
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return object!.isKindOfClass(SenderSpy.self);
    }
}