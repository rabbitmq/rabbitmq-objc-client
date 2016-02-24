@objc class NothingSentYet : AMQFrameset {}

@objc class FakeSender : NSObject, RMQSender {
    var lastWaitedUponFrameset: AMQFrameset = AMQFrameset()
    var lastSentFrameset: AMQFrameset = NothingSentYet()
    var methodWaitedUpon: String = "nothing waited upon yet!"
    var channelWaitedUpon: NSNumber = -1

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