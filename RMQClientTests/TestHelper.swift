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

    static func assertEqualBytes(expected: NSData, _ actual: NSData, _ message: String = "") {
        if message == "" {
            XCTAssertEqual(expected, actual, "\n\nBytes not equal:\n\(expected)\n\(actual)")
        } else {
            XCTAssertEqual(expected, actual, message)
        }
    }

    static func startedConnection(
        transport: RMQTransport,
        delegateQueue: dispatch_queue_t = dispatch_get_main_queue(),
        networkQueue: dispatch_queue_t = dispatch_get_main_queue(),
        delegate: RMQConnectionDelegate? = nil,
        syncTimeout: Double = 0,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
        let allocator = RMQMultipleChannelAllocator()
        let conn = RMQConnection(
            transport: transport,
            user: user,
            password: password,
            vhost: vhost,
            channelMax: 65535,
            frameMax: 131072,
            heartbeat: 0,
            syncTimeout: syncTimeout,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            delegateQueue: delegateQueue,
            networkQueue: networkQueue
        )
        conn.start()
        return conn
    }

    static func connectionAfterHandshake() -> (transport: ControlledInteractionTransport, q: QueueHelper, conn: RMQConnection, delegate: ConnectionDelegateSpy) {
        let transport = ControlledInteractionTransport()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        let conn = TestHelper.startedConnection(transport,
                                                delegateQueue: q.dispatchQueue,
                                                networkQueue: q.dispatchQueue,
                                                delegate: delegate)
        q.finish()
        transport.handshake()

        return (transport, q, conn, delegate)
    }

}