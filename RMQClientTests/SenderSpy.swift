@objc class NothingSentYet : AMQFrameset {}

@objc class SenderSpy : NSObject, RMQSender {
    var lastWaitedUponFrameset: AMQFrameset = AMQFrameset()
    var lastSentFrameset: AMQFrameset = NothingSentYet()
    var methodWaitedUpon: String = "nothing waited upon yet!"
    var channelWaitedUpon: NSNumber = -1
    var frameMax: NSNumber

    init(frameMax aFrameMax: Int = 131072) {
        frameMax = aFrameMax
    }

    func send(encodable: AMQEncoding) {
        lastSentFrameset = encodable as! AMQFrameset
    }

    func sendMethod(amqMethod: AMQMethod, channelID: NSNumber) {

    }

    func waitOnMethod(amqMethodClass: AnyClass, channelID: NSNumber) throws {
        methodWaitedUpon = "\(amqMethodClass)"
        channelWaitedUpon = channelID
    }
}