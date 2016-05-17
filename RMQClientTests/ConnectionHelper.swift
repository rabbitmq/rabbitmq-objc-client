class ConnectionHelper {
    static func connectionConfig(vhost vhost: String = "",
                                       channelMax: Int = 123,
                                       frameMax: Int = 321,
                                       heartbeat: Int = 10) -> RMQConnectionConfig {
        let nullRecovery = RMQConnectionShutdown(heartbeatSender: HeartbeatSenderSpy())
        return RMQConnectionConfig(credentials: RMQCredentials(username: "foo", password: "bar"),
                                   channelMax: channelMax,
                                   frameMax: frameMax,
                                   heartbeat: heartbeat,
                                   vhost: vhost,
                                   authMechanism: "PLAIN",
                                   recovery: nullRecovery)
    }

    static func startedConnection(
        transport: RMQTransport,
        commandQueue: RMQLocalSerialQueue = RMQGCDSerialQueue(name: "started connection command queue"),
        delegate: RMQConnectionDelegate? = nil,
        syncTimeout: Double = 0,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)
        let config = connectionConfig(vhost: vhost, channelMax: 65536, frameMax: 131072, heartbeat: 0)
        let conn = RMQConnection(
            transport: transport,
            config: config,
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            commandQueue: commandQueue,
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.start()
        return conn
    }

    static func connectionAfterHandshake() -> (transport: ControlledInteractionTransport, q: FakeSerialQueue, conn: RMQConnection, delegate: ConnectionDelegateSpy) {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let conn = ConnectionHelper.startedConnection(transport,
                                                      commandQueue: q,
                                                      delegate: delegate)
        try! q.step()
        transport.handshake()

        return (transport, q, conn, delegate)
    }
}