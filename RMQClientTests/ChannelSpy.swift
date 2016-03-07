@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber
    var lastReceivedBasicConsumeBlock: ((RMQMessage) -> Void)?
    var lastReceivedFrameset: AMQFrameset?

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
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