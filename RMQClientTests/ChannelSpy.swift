enum ChannelSpyError: ErrorType {
    case ArbitraryError(localizedDescription: String)
}

@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber
    var lastReceivedBasicConsumeOptions: AMQBasicConsumeOptions = []
    var lastReceivedBasicConsumeBlock: ((RMQMessage) -> Void)?
    var lastReceivedBasicGetQueue: String?
    var lastReceivedBasicGetOptions: AMQBasicGetOptions?
    var lastReceivedBasicGetCompletionHandler: ((RMQMessage) -> Void)?
    var lastReceivedBasicPublishMessage: String?
    var lastReceivedBasicPublishRoutingKey: String?
    var lastReceivedBasicPublishExchange: String?
    var lastReceivedFrameset: AMQFrameset?
    var queues: [String: RMQQueue] = [:]
    var stubbedMessageCount: AMQLong = AMQLong(0)
    var stubbedConsumerCount: AMQLong = AMQLong(0)
    var lastReceivedQueueDeclareOptions: AMQQueueDeclareOptions = []
    var stubbedBasicConsumeError: String?
    var openCalled = false
    var delegateSentToActivate: RMQConnectionDelegate?
    override var description: String {
        return "Channel Spy \(channelNumber)"
    }

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange()
    }

    func activateWithDelegate(delegate: RMQConnectionDelegate?) {
        delegateSentToActivate = delegate
    }

    func open() {
        openCalled = true
    }

    func sendMethod(sendingMethod: AMQMethod,
                    waitOnMethod waitOnMethodClass: AnyClass,
                    completionHandler: (AMQFrameset?, NSError?) -> Void) {
    }

    func queue(queueName: String, options: AMQQueueDeclareOptions) -> RMQQueue {
        if let foundQueue = queues[queueName] {
            return foundQueue;
        } else {
            let q = RMQQueue(name: queueName, channel: self, sender: SenderSpy())
            queues[queueName] = q
            return q
        }
    }

    func queue(queueName: String) -> RMQQueue {
        return queue(queueName, options: [])
    }

    func queueDeclare(queueName: String, options: AMQQueueDeclareOptions) -> AMQQueueDeclareOk {
        lastReceivedQueueDeclareOptions = options
        return AMQQueueDeclareOk(
            queue: AMQShortstr(queueName),
            messageCount: stubbedMessageCount,
            consumerCount: stubbedConsumerCount
        )
    }

    func basicConsume(queueName: String, options: AMQBasicConsumeOptions, consumer: (RMQMessage) -> Void) {
        lastReceivedBasicConsumeOptions = options
        lastReceivedBasicConsumeBlock = consumer
        if let msg = stubbedBasicConsumeError {
            let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            delegateSentToActivate?.channel(self, error: e)
        }
    }

    func basicPublish(message: String, routingKey: String, exchange: String) {
        lastReceivedBasicPublishMessage = message
        lastReceivedBasicPublishRoutingKey = routingKey
        lastReceivedBasicPublishExchange = exchange
    }

    func basicGet(queue: String, options: AMQBasicGetOptions, completionHandler: (RMQMessage) -> Void) {
        lastReceivedBasicGetQueue = queue
        lastReceivedBasicGetOptions = options
        lastReceivedBasicGetCompletionHandler = completionHandler
    }

    func ack(deliveryTag: NSNumber, options: AMQBasicAckOptions) {
    }

    func ack(deliveryTag: NSNumber) {
    }

    func handleFrameset(frameset: AMQFrameset) {
        lastReceivedFrameset = frameset
    }

    func basicQos(count: NSNumber, global isGlobal: Bool) {
    }

    func reject(deliveryTag: NSNumber, options: AMQBasicRejectOptions) {
    }

    func reject(deliveryTag: NSNumber) {
    }

    func nack(deliveryTag: NSNumber, options: AMQBasicNackOptions) {
    }

    func nack(deliveryTag: NSNumber) {
    }
}
