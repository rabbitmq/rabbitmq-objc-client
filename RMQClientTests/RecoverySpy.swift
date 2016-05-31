@objc class RecoverySpy : NSObject, RMQConnectionRecovery {
    var interval: NSNumber! = 0.1
    var connectionPassedToRecover: RMQStarter?
    var allocatorPassedToRecover: RMQChannelAllocator?
    var errorPassedToRecover: NSError?
    
    func recover(connection: RMQStarter!, channelAllocator allocator: RMQChannelAllocator!, error: NSError!) {
        connectionPassedToRecover = connection
        allocatorPassedToRecover = allocator
        errorPassedToRecover = error
    }

    func connectionConfig() -> RMQConnectionConfig {
        return RMQConnectionConfig(credentials: RMQCredentials(username: "", password: ""),
                                   channelMax: 10,
                                   frameMax: 4096,
                                   heartbeat: 10,
                                   vhost: "",
                                   authMechanism: "PLAIN",
                                   recovery: self)
    }
}