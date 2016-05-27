@objc class RecoverySpy : NSObject, RMQConnectionRecovery {
    var recoverCalled = false
    var interval: NSNumber! = 0.1
    
    func recover(connection: RMQStarter!, channelAllocator allocator: RMQChannelAllocator!) {
        recoverCalled = true
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