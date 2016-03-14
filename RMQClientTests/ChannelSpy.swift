@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber
    var lastReceivedBasicConsumeBlock: ((RMQMessage) -> Void)?
    var lastReceivedFrameset: AMQFrameset?
    var queues: [String: RMQQueue] = [:]

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange()
    }

    func queue(queueName: String, autoDelete shouldAutoDelete: Bool, exclusive isExclusive: Bool) -> RMQQueue {
        let foundQueue = queues[queueName]
        if foundQueue != nil {
            return foundQueue!;
        } else {
            let q = RMQQueue(name: queueName, channel: self, sender: SenderSpy())
            queues[queueName] = q
            return q
        }
    }

    func basicConsume(queueName: String, consumer: (RMQMessage) -> Void) {
        lastReceivedBasicConsumeBlock = consumer
    }

    func handleFrameset(frameset: AMQFrameset) {
        lastReceivedFrameset = frameset
    }
}