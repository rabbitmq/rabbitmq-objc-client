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

    static func startedConnection(
        transport: RMQTransport,
        delegateQueue: dispatch_queue_t = dispatch_get_main_queue(),
        networkQueue: RMQLocalSerialQueue = RMQGCDSerialQueue(),
        delegate: RMQConnectionDelegate? = nil,
        syncTimeout: Double = 0,
        user: String = "foo",
        password: String = "bar",
        vhost: String = "baz"
        ) -> RMQConnection {
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)
        let conn = RMQConnection(
            transport: transport,
            user: user,
            password: password,
            vhost: vhost,
            channelMax: 65535,
            frameMax: 131072,
            heartbeat: 0,
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            delegateQueue: delegateQueue,
            networkQueue: networkQueue,
            waiterFactory: RMQSemaphoreWaiterFactory()
        )
        conn.start()
        return conn
    }

    static func connectionAfterHandshake() -> (transport: ControlledInteractionTransport, q: FakeSerialQueue, conn: RMQConnection, delegate: ConnectionDelegateSpy) {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        let conn = TestHelper.startedConnection(transport,
                                                delegateQueue: dispatch_get_main_queue(),
                                                networkQueue: q,
                                                delegate: delegate)
        try! q.step()
        transport.handshake()

        return (transport, q, conn, delegate)
    }

    static func handshakeAsync(transport: ControlledInteractionTransport, q: QueueHelper) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while transport.readCallbacks.isEmpty { usleep(10) }
            transport.handshake()
        }
        q.finish()
    }

}