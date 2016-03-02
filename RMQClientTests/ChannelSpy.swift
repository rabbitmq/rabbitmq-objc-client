@objc class ChannelSpy : NSObject, RMQChannel {
    var channelID: NSNumber
    var lastReceivedBasicConsumeBlock: ((RMQMessage) -> Void)?
    var lastReceivedFrameset: AMQFrameset?

    init(_ aChannelID: Int) {
        channelID = aChannelID
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange()
    }

    func queue(queueName: String, autoDelete shouldAutoDelete: Bool, exclusive isExclusive: Bool) -> RMQQueue {
        return RMQQueue()
    }

    func basicConsume(queueName: String, consumer: (RMQMessage) -> Void) {
        lastReceivedBasicConsumeBlock = consumer
    }

    func handleFrameset(frameset: AMQFrameset) {
        lastReceivedFrameset = frameset
    }
}