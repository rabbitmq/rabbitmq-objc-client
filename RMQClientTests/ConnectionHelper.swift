class ConnectionHelper {
    static func makeConnection(recoveryInterval interval: Int = 2,
                                                transport: RMQTCPSocketTransport,
                                                delegate: RMQConnectionDelegate) -> RMQConnection {
        let credentials = RMQCredentials(username: "guest", password: "guest")
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 10)
        let heartbeatSender = RMQGCDHeartbeatSender(transport: transport, clock: RMQTickingClock())
        let commandQueue = RMQGCDSerialQueue(name: "socket-recovery-test-queue")
        let recovery = RMQConnectionRecover(interval: interval,
                                            attemptLimit: 1,
                                            onlyErrors: true,
                                            heartbeatSender: heartbeatSender,
                                            commandQueue: commandQueue,
                                            delegate: delegate)
        let config = RMQConnectionConfig(credentials: credentials,
                                         channelMax: RMQChannelLimit,
                                         frameMax: RMQFrameMax,
                                         heartbeat: 60,
                                         vhost: "/",
                                         authMechanism: "PLAIN",
                                         recovery: recovery)
        return RMQConnection(transport: transport,
                             config: config,
                             handshakeTimeout: 10,
                             channelAllocator: allocator,
                             frameHandler: allocator,
                             delegate: delegate,
                             commandQueue: commandQueue,
                             waiterFactory: RMQSemaphoreWaiterFactory(),
                             heartbeatSender: heartbeatSender)
    }
}