import XCTest

enum RecoveryTestError : ErrorType {
    case TimeOutWaitingForConnectionCountToDrop
}

class ConnectionRecoveryIntegrationTest: XCTestCase {
    let httpAPI = RMQHTTP("http://guest:guest@localhost:15672/api")

    func testReenablesConsumersOnEachRecovery() {
        let uri = "amqp://guest:guest@localhost"
        let env = NSProcessInfo.processInfo().environment
        let recoveryInterval = 2
        let semaphoreTimeout: Double = 30
        let conn = RMQConnection(uri: uri,
                                 tlsOptions: RMQTLSOptions.fromURI(uri),
                                 channelMax: 1000,
                                 frameMax: 131072,
                                 heartbeat: 10,
                                 syncTimeout: 10,
                                 delegate: ConnectionDelegateSpy(),
                                 delegateQueue: dispatch_get_main_queue(),
                                 recoverAfter: recoveryInterval)
        conn.start()
        defer { conn.blockingClose() }
        let ch = conn.createChannel()
        let q = ch.queue("")
        let ex = ch.direct("foo")
        let semaphore = dispatch_semaphore_create(0)
        var messages: [RMQMessage] = []

        q.bind(ex)

        q.subscribe { (_, m) in
            messages.append(m)
            dispatch_semaphore_signal(semaphore)
        }

        ex.publish("before close")
        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        try! closeAllConnections()

        q.publish("after close 1")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 2")
        dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual(["before close", "after close 1", "after close 2"], messages.map { $0.content })

        try! closeAllConnections()

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
