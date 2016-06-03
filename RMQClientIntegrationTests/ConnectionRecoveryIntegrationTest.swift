import XCTest

enum RecoveryTestError : ErrorType {
    case TimeOutWaitingForConnectionCountToDrop
}

class ConnectionRecoveryIntegrationTest: XCTestCase {
    let amqpLocalhost = "amqp://guest:guest@127.0.0.1"
    let httpAPI = RMQHTTP("http://guest:guest@127.0.0.1:15672/api")

    func testRecoversFromSocketDisconnect() {
        let recoveryInterval = 2
        let semaphoreTimeout: Double = 30
        let delegate = ConnectionDelegateSpy()

        let tlsOptions = RMQTLSOptions.fromURI(amqpLocalhost)
        let transport = RMQTCPSocketTransport(host: "127.0.0.1", port: 5672, tlsOptions: tlsOptions)
        let credentials = RMQCredentials(username: "guest", password: "guest")
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 10)
        let heartbeatSender = RMQGCDHeartbeatSender(transport: transport, clock: RMQTickingClock())
        let commandQueue = RMQGCDSerialQueue(name: "socket-recovery-test-queue")
        let recovery = RMQConnectionRecover(interval: recoveryInterval,
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
        let conn = RMQConnection(transport: transport,
                                 config: config,
                                 handshakeTimeout: 10,
                                 channelAllocator: allocator,
                                 frameHandler: allocator,
                                 delegate: delegate,
                                 commandQueue: commandQueue,
                                 waiterFactory: RMQSemaphoreWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])
        let ex = ch.direct("foo", options: [.AutoDelete])
        let ex2 = ch.direct("bar", options: [.AutoDelete])
        let semaphore = dispatch_semaphore_create(0)
        var messages: [RMQMessage] = []

        ex2.bind(ex)
        q.bind(ex2)

        q.subscribe { m in
            messages.append(m)
            dispatch_semaphore_signal(semaphore)
        }

        ex.publish("before close")
        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        transport.simulateDisconnect()

        XCTAssert(TestHelper.pollUntil { delegate.recoveredConnection != nil },
                  "Didn't finish recovery")
        delegate.recoveredConnection = nil

        q.publish("after close 1")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 2")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual(["before close", "after close 1", "after close 2"], messages.map { $0.content })
    }

    func testReenablesConsumersOnEachRecoveryFromConnectionClose() {
        let recoveryInterval = 2
        let semaphoreTimeout: Double = 30
        let delegate = ConnectionDelegateSpy()

        let conn = RMQConnection(uri: amqpLocalhost,
                                 tlsOptions: RMQTLSOptions.fromURI(amqpLocalhost),
                                 channelMax: RMQChannelLimit,
                                 frameMax: RMQFrameMax,
                                 heartbeat: 10,
                                 syncTimeout: 10,
                                 delegate: delegate,
                                 delegateQueue: dispatch_get_main_queue(),
                                 recoverAfter: recoveryInterval,
                                 recoveryAttempts: 2,
                                 recoverFromConnectionClose: true)
        conn.start()
        defer { conn.blockingClose() }
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])
        let ex = ch.direct("foo", options: [.AutoDelete])
        let semaphore = dispatch_semaphore_create(0)
        var messages: [RMQMessage] = []

        q.bind(ex)

        q.subscribe { m in
            messages.append(m)
            dispatch_semaphore_signal(semaphore)
        }

        ex.publish("before close")
        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        try! closeAllConnections()

        XCTAssert(TestHelper.pollUntil { delegate.recoveredConnection != nil },
                  "Didn't finish recovery the first time")
        delegate.recoveredConnection = nil

        q.publish("after close 1")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 2")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual(["before close", "after close 1", "after close 2"], messages.map { $0.content })

        try! closeAllConnections()

        XCTAssert(TestHelper.pollUntil { delegate.recoveredConnection != nil },
                  "Didn't finish recovery the second time")

        q.publish("after close 3")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 4")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual(["before close", "after close 1", "after close 2", "after close 3", "after close 4"], messages.map { $0.content })
    }

    private func connections() -> [RMQHTTPConnection] {
        return RMQHTTPParser().connections(httpAPI.get("/connections"))
    }

    private func closeAllConnections() throws {
        let conns = connections()
        XCTAssertGreaterThan(conns.count, 0)

        for conn in conns {
            let escapedName = conn.name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let path = "/connections/\(escapedName)"
            httpAPI.delete(path)
        }

        if (!TestHelper.pollUntil(30) { self.connections().count == 0 }) {
            throw RecoveryTestError.TimeOutWaitingForConnectionCountToDrop
        }
    }

}
