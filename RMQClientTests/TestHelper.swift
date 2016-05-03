import XCTest

class TestHelper {

    static func pollUntil(checker: () -> Bool) -> Bool {
        for _ in 1...10 {
            if checker() {
                return true
            } else {
                run(0.5)
            }
        }
        return false
    }

    static func pollUntil(timeout: NSTimeInterval, checker: () -> Bool) -> Bool {
        let startTime = NSDate()
        while NSDate().timeIntervalSinceDate(startTime) < timeout {
            if checker() {
                return true
            } else {
                run(0.5)
            }
        }
        return false
    }

    static func run(time: NSTimeInterval) {
        NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(time))
    }

    static func dispatchTimeFromNow(seconds: Double) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    }

    static func assertEqualBytes(expected: NSData, _ actual: NSData, _ message: String = "") {
        if message == "" {
            XCTAssertEqual(expected, actual, "\n\nBytes not equal:\n\(expected)\n\(actual)")
        } else {
            XCTAssertEqual(expected, actual, message)
        }
    }

    static func connectionConfig(vhost vhost: String = "",
                                       channelMax: Int = 123,
                                       frameMax: Int = 321,
                                       heartbeat: Int = 10) -> RMQConnectionConfig {
        return RMQConnectionConfig(credentials: RMQCredentials(username: "foo", password: "bar"),
                                   channelMax: channelMax,
                                   frameMax: frameMax,
                                   heartbeat: heartbeat,
                                   vhost: vhost,
                                   authMechanism: "PLAIN")
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
        let conn = RMQConnection(
            transport: transport,
            config: RMQConnectionConfig(credentials: RMQCredentials(username: user, password: password),
                channelMax: 65536, frameMax: 131072, heartbeat: 0, vhost: vhost, authMechanism: "PLAIN"),
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
        let conn = TestHelper.startedConnection(transport,
                                                commandQueue: q,
                                                delegate: delegate)
        try! q.step()
        transport.handshake()

        return (transport, q, conn, delegate)
    }

}