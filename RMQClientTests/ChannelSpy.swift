enum ChannelSpyError: ErrorType {
    case ArbitraryError(localizedDescription: String)
}

@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber
    var lastReceivedBasicConsumeOptions: RMQBasicConsumeOptions = []
    var lastReceivedBasicConsumeBlock: RMQConsumer?
    var lastReceivedBasicGetQueue: String?
    var lastReceivedBasicGetOptions: RMQBasicGetOptions?
    var lastReceivedBasicGetCompletionHandler: RMQConsumer?
    var lastReceivedBasicPublishMessage: String?
    var lastReceivedBasicPublishRoutingKey: String?
    var lastReceivedBasicPublishExchange: String?
    var lastReceivedBasicPublishPersistent: Bool?
    var lastReceivedQueueBindQueueName: String?
    var lastReceivedQueueBindExchange: String?
    var lastReceivedQueueBindRoutingKey: String?
    var lastReceivedFrameset: RMQFrameset?
    var queues: [String: RMQQueue] = [:]
    var stubbedMessageCount: RMQLong = RMQLong(0)
    var stubbedConsumerCount: RMQLong = RMQLong(0)
    var lastReceivedQueueDeclareOptions: RMQQueueDeclareOptions = []
    var stubbedBasicConsumeError: String?
    var openCalled = false
    var blockingCloseCalled = false
    var delegateSentToActivate: RMQConnectionDelegate?

    override var description: String {
        return "Channel Spy \(channelNumber)"
    }

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange(name: "", channel: self)
    }

    func activateWithDelegate(delegate: RMQConnectionDelegate?) {
        delegateSentToActivate = delegate
    }

    func open() {
        openCalled = true
    }

    func blockingClose() {
        blockingCloseCalled = true
    }

    func sendMethod(sendingMethod: RMQMethod,
                    waitOnMethod waitOnMethodClass: AnyClass,
                    completionHandler: (RMQFrameset?, NSError?) -> Void) {
    }

    func queue(queueName: String, options: RMQQueueDeclareOptions) -> RMQQueue {
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

    func queueDeclare(queueName: String, options: RMQQueueDeclareOptions) -> RMQQueueDeclareOk {
        lastReceivedQueueDeclareOptions = options
        return RMQQueueDeclareOk(
            queue: RMQShortstr(queueName),
            messageCount: stubbedMessageCount,
            consumerCount: stubbedConsumerCount
        )
    }

    func queueBind(queueName: String, exchange exchangeName: String, routingKey: String) {
        lastReceivedQueueBindQueueName = queueName
        lastReceivedQueueBindExchange = exchangeName
        lastReceivedQueueBindRoutingKey = routingKey
    }

    func queueUnbind(queueName: String, exchange exchangeName: String, routingKey: String) {
    }

    func basicConsume(queueName: String, options: RMQBasicConsumeOptions, consumer: RMQConsumer) {
        lastReceivedBasicConsumeOptions = options
        lastReceivedBasicConsumeBlock = consumer
        if let msg = stubbedBasicConsumeError {
            let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            delegateSentToActivate?.channel(self, error: e)
        }
    }

    func basicPublish(message: String, routingKey: String, exchange: String, persistent isPersistent: Bool) {
        lastReceivedBasicPublishMessage = message
        lastReceivedBasicPublishRoutingKey = routingKey
        lastReceivedBasicPublishExchange = exchange
        lastReceivedBasicPublishPersistent = isPersistent
    }

    func basicGet(queue: String, options: RMQBasicGetOptions, completionHandler: RMQConsumer) {
        lastReceivedBasicGetQueue = queue
        lastReceivedBasicGetOptions = options
        lastReceivedBasicGetCompletionHandler = completionHandler
    }

    func ack(deliveryTag: NSNumber, options: RMQBasicAckOptions) {
    }

    func ack(deliveryTag: NSNumber) {
    }

    func handleFrameset(frameset: RMQFrameset) {
        lastReceivedFrameset = frameset
    }

    func basicQos(count: NSNumber, global isGlobal: Bool) {
    }

    func reject(deliveryTag: NSNumber, options: RMQBasicRejectOptions) {
    }

    func reject(deliveryTag: NSNumber) {
    }

    func nack(deliveryTag: NSNumber, options: RMQBasicNackOptions) {
    }

    func nack(deliveryTag: NSNumber) {
    }

    func exchangeDeclare(name: String, type: String, options: RMQExchangeDeclareOptions) {
    }

    func fanout(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, channel: self)
    }

    func fanout(name: String) -> RMQExchange {
        return fanout(name, options: [])
    }

    func direct(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, channel: self)
    }

    func direct(name: String) -> RMQExchange {
        return direct(name, options: [])
    }

    func topic(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, channel: self)
    }

    func topic(name: String) -> RMQExchange {
        return topic(name, options: [])
    }
}
