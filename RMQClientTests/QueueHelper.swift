class QueueHelper {

    static func makeQueue(channel: RMQChannel,
                          name: String = "",
                          options: RMQQueueDeclareOptions = [],
                          arguments: [String: RMQValue] = [:]) -> RMQQueue {
        return RMQQueue(name: name, options: options, arguments: RMQTable(arguments), channel: channel)
    }

}