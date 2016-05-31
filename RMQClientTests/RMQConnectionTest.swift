import XCTest

class RMQConnectionTest: XCTestCase {
    func testImmediateConnectionErrorIsSentToDelegate() {
        let transport = ControlledInteractionTransport()
        transport.stubbedToThrowErrorOnConnect = "bad connection"
        let delegate = ConnectionDelegateSpy()
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)
        let conn = RMQConnection(
            transport: transport,
            config: ConnectionHelper.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            commandQueue: FakeSerialQueue(),
            waiterFactory: RMQSemaphoreWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        XCTAssertNil(delegate.lastConnectionError)
        conn.start()
        XCTAssertEqual("bad connection", delegate.lastConnectionError!.localizedDescription)
    }

    func testErrorSentToDelegateOnHandshakeTimeout() {
        let transport = ControlledInteractionTransport()
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 10)
        let delegate = ConnectionDelegateSpy()
        let q = FakeSerialQueue()
        let conn = RMQConnection(
            transport: transport,
            config: ConnectionHelper.connectionConfig(),
            handshakeTimeout: 0,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            commandQueue: q,
            waiterFactory: RMQSemaphoreWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.start()
        try! q.step()

        XCTAssertEqual("Handshake timed out.", delegate.lastConnectionError?.localizedDescription)
    }

    func testTransportDelegateWriteErrorsAreTransformedIntoConnectionDelegateErrors() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        ConnectionHelper.startedConnection(transport,
                                           commandQueue: q,
                                           delegate: delegate)
        transport.stubbedToProduceErrorOnWrite = "fail please"
        try! q.step()
        transport.handshake()

        XCTAssertEqual("fail please", delegate.lastWriteError!.localizedDescription)
    }

    func testTransportDelegateDisconnectErrorsAreTransformedIntoConnectionDelegateErrors() {
        let transport = ControlledInteractionTransport()
        let delegate = ConnectionDelegateSpy()
        let conn = ConnectionHelper.startedConnection(transport, delegate: delegate)
        let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "foo"])

        conn.transport(nil, disconnectedWithError: e)

        XCTAssertEqual("foo", delegate.lastDisconnectError!.localizedDescription)
    }

    func testTransportDisconnectNotificationsNotTransformedWhenCloseRequested() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        conn.close()
        conn.transport(nil, disconnectedWithError: nil)

        XCTAssertFalse(delegate.disconnectCalled)
    }

    func testTransportDisconnectErrorTriggersRecovery() {
        let transport = ControlledInteractionTransport()
        let recovery = RecoverySpy()
        let allocator = ChannelSpyAllocator()
        let conn = RMQConnection(
            transport: transport,
            config: recovery.connectionConfig(),
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            commandQueue: FakeSerialQueue(),
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: HeartbeatSenderSpy()
        )
        conn.transport(transport, disconnectedWithError: nil)

        XCTAssertEqual(conn, recovery.connectionPassedToRecover as? RMQConnection)
        XCTAssertEqual(allocator, recovery.allocatorPassedToRecover as? ChannelSpyAllocator)
    }

    func testSignalsActivityToHeartbeatSenderOnOutgoingFrameset() {
        let heartbeatSender = HeartbeatSenderSpy()
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionHelper.connectionConfig(),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 commandQueue: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        conn.start()
        try! q.step()
        transport.handshake()

        heartbeatSender.signalActivityReceived = false

        conn.sendFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()))

        XCTAssertEqual(MethodFixtures.channelOpen(), transport.lastSentPayload() as? RMQChannelOpen)
        XCTAssert(heartbeatSender.signalActivityReceived)
    }

    func testDelaysTransportSendAndHeartbeatSignalWhenInRecovery() {
        let heartbeatSender = HeartbeatSenderSpy()
        let recovery = RecoverySpy()
        let q = FakeSerialQueue()
        let transport = ControlledInteractionTransport()
        let conn = RMQConnection(transport: transport,
                                 config: recovery.connectionConfig(),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 commandQueue: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: heartbeatSender)
        recovery.interval = 1
        conn.start()
        try! q.step()
        // handshake not yet complete, simulating recovery mode

        transport.outboundData = []

        conn.sendFrameset(RMQFrameset(channelNumber: 1, method: MethodFixtures.channelOpen()))

        XCTAssertFalse(heartbeatSender.signalActivityReceived)
        XCTAssertEqual(0, transport.outboundData.count)
        XCTAssertEqual(1, q.delayedItems.count)

        try! q.step()

        XCTAssertEqual(MethodFixtures.channelOpen(), transport.lastSentPayload() as? RMQChannelOpen)
        XCTAssert(heartbeatSender.signalActivityReceived)
    }

    func testSendsVersionNumberWithStartOk() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionHelper.connectionConfig(vhost: ""),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 commandQueue: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())
        conn.start()
        try! q.step()

        transport.serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)

        let parser = RMQParser(data: transport.outboundData.last!)
        let outgoingStartOk: RMQConnectionStartOk = RMQFrame(parser: parser).payload as! RMQConnectionStartOk

        XCTAssert(outgoingStartOk.description().rangeOfString(TestHelper.frameworkVersion()) != nil)
    }

    func testSendsConfiguredVHostWithConnectionOpen() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let conn = RMQConnection(transport: transport,
                                 config: ConnectionHelper.connectionConfig(vhost: "/myvhost"),
                                 handshakeTimeout: 10,
                                 channelAllocator: ChannelSpyAllocator(),
                                 frameHandler: FrameHandlerSpy(),
                                 delegate: ConnectionDelegateSpy(),
                                 commandQueue: q,
                                 waiterFactory: FakeWaiterFactory(),
                                 heartbeatSender: HeartbeatSenderSpy())
        conn.start()
        try! q.step()

        transport.handshake()

        let parser = RMQParser(data: transport.outboundData.last!)
        let outgoingConnectionOpen: RMQConnectionOpen = RMQFrame(parser: parser).payload as! RMQConnectionOpen

        XCTAssertEqual("/myvhost", outgoingConnectionOpen.virtualHost.stringValue)
    }

    func testSpecialCharsInURISendsErrorToDelegate() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(uri: "amqps://other:wise@valid`oops", delegate: delegate)
        conn.start()
        XCTAssert(TestHelper.pollUntil { delegate.lastConnectionError != nil },
                  "Timed out waiting for a connection error with invalid URI")
    }

}
