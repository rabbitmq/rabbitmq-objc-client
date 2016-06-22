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

        let conn = ConnectionHelper.makeConnection(recoveryInterval: recoveryInterval, transport: transport, delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let q = ch.queue("", options: [.Exclusive], arguments: ["x-max-length" : RMQShort(3)])
        let ex1 = ch.direct("foo", options: [.AutoDelete])
        let ex2 = ch.direct("bar", options: [.AutoDelete])
        let consumerSemaphore = dispatch_semaphore_create(0)
        let confirmSemaphore = dispatch_semaphore_create(0)

        ex2.bind(ex1)
        q.bind(ex2)

        var messages: [RMQMessage] = []
        let consumer = q.subscribe { m in
            messages.append(m)
            dispatch_semaphore_signal(consumerSemaphore)
        }

        ch.confirmSelect()

        ex1.publish("before close")
        XCTAssertEqual(0, dispatch_semaphore_wait(consumerSemaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        transport.simulateDisconnect()

        XCTAssert(TestHelper.pollUntil { delegate.recoveredConnection != nil },
                  "Didn't finish recovery")

        q.publish("after close 1")
        dispatch_semaphore_wait(consumerSemaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex1.publish("after close 2")
        dispatch_semaphore_wait(consumerSemaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        var acks: Set<NSNumber>?
        var nacks: Set<NSNumber>?
        ch.afterConfirmed { (a, n) in
            acks = a
            nacks = n
            dispatch_semaphore_signal(confirmSemaphore)
        }

        XCTAssertEqual(["before close", "after close 1", "after close 2"], messages.map { $0.content })

        XCTAssertEqual(0, dispatch_semaphore_wait(confirmSemaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)))
        XCTAssert(acks!.union(nacks!).isSupersetOf([2, 3]),
                  "Didn't receive acks for publications post-recovery (pre-recovery acks can be lost)")

        // test recovery of queue arguments - in this case, x-max-length
        consumer.cancel()
        q.publish("4")
        q.publish("5")
        q.publish("6")
        q.publish("7")

        var messagesPostCancel: [RMQMessage] = []
        q.subscribe { m in
            messagesPostCancel.append(m)
            dispatch_semaphore_signal(consumerSemaphore)
        }

        for _ in 5...7 {
            XCTAssertEqual(0, dispatch_semaphore_wait(consumerSemaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)))
        }
        XCTAssertEqual(["5", "6", "7"], messagesPostCancel.map { $0.content })
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
