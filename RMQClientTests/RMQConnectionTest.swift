import XCTest

class RMQConnectionTest: XCTestCase {

    func testImmediateConnectionErrorIsSentToDelegate() {
        let transport = ControlledInteractionTransport()
        transport.stubbedToThrowErrorOnConnect = "bad connection"
        let delegate = ConnectionDelegateSpy()
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)
        let conn = RMQConnection(
            transport: transport,
            user: "foo",
            password: "bar",
            vhost: "",
            channelMax: 123,
            frameMax: 321,
            heartbeat: 10,
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            commandQueue: FakeSerialQueue(),
            waiterFactory: RMQSemaphoreWaiterFactory()
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
            user: "foo",
            password: "bar",
            vhost: "",
            channelMax: 123,
            frameMax: 321,
            heartbeat: 10,
            handshakeTimeout: 0,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: delegate,
            commandQueue: q,
            waiterFactory: RMQSemaphoreWaiterFactory()
        )
        conn.start()
        try! q.step()

        XCTAssertEqual("Handshake timed out.", delegate.lastConnectionError?.localizedDescription)
    }

    func testTransportDelegateWriteErrorsAreTransformedIntoConnectionDelegateErrors() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let delegate = ConnectionDelegateSpy()
        TestHelper.startedConnection(transport,
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
        let conn = TestHelper.startedConnection(transport, delegate: delegate)
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

    func testTransportDisconnectNotificationsTransformedWhenCloseNotRequested() {
        let transport = ControlledInteractionTransport()
        let delegate = ConnectionDelegateSpy()
        let conn = TestHelper.startedConnection(transport, delegate: delegate)
        conn.transport(transport, disconnectedWithError: nil)

        XCTAssertNil(delegate.lastDisconnectError)
        XCTAssertTrue(delegate.disconnectCalled)
    }

    func testClientInitiatedClosingAfterHandshake() {
        let (transport, q, conn, _) = TestHelper.connectionAfterHandshake()

        conn.close()

        try! q.step()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testBlockingCloseWaitsOnQueue() {
        let q = FakeSerialQueue()
        let waiterFactory = FakeWaiterFactory()
        let delegate = ConnectionDelegateSpy()
        let transport = ControlledInteractionTransport()
        let conn = RMQConnection(transport: transport, user: "", password: "", vhost: "", channelMax: 10, frameMax: 11, heartbeat: 12, handshakeTimeout: 10, channelAllocator: ChannelSpyAllocator(), frameHandler: FrameHandlerSpy(), delegate: delegate, commandQueue: q, waiterFactory: waiterFactory)
        conn.start()
        try! q.step()
        transport.handshake()

        conn.blockingClose()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)

        // TODO: expect close-ok before unblocking
    }

    func testClientInitiatedClosingWaitsForHandshakeToComplete() {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let tuneOk = MethodFixtures.connectionTuneOk()
        let delegate = ConnectionDelegateSpy()
        let waiterFactory = FakeWaiterFactory()
        let conn = RMQConnection(
            transport: transport,
            user: "",
            password: "",
            vhost: "",
            channelMax: tuneOk.channelMax.integerValue,
            frameMax: tuneOk.frameMax.integerValue,
            heartbeat: tuneOk.heartbeat.integerValue,
            handshakeTimeout: 1,
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: delegate,
            commandQueue: q,
            waiterFactory: waiterFactory
        )
        conn.start()
        conn.close()

        XCTAssertEqual(2, q.items.count)
        try! q.step()
        transport.serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
        transport.serverSendsPayload(MethodFixtures.connectionTune(), channelNumber: 0)
        transport.serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)

        try! q.step()
        transport.assertClientSentMethods([MethodFixtures.connectionOpen(), MethodFixtures.connectionClose()],
                                          channelNumber: 0)
        XCTAssert(transport.isConnected())

        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())

        XCTAssertNil(delegate.lastConnectionError)
    }

    func testClientInitiatedClosingWaitsForChannelsToCloseBeforeSendingClose() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = FakeSerialQueue()
        let waiterFactory = FakeWaiterFactory()
        let conn = RMQConnection(
            transport: transport,
            user: "",
            password: "",
            vhost: "",
            channelMax: 4,
            frameMax: 5,
            heartbeat: 6,
            handshakeTimeout: 100,
            channelAllocator: allocator,
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            commandQueue: q,
            waiterFactory: waiterFactory
        )
        conn.start()
        try! q.step()
        transport.handshake()

        conn.createChannel()
        conn.createChannel()
        conn.createChannel()
        try! q.step()
        try! q.step()
        try! q.step()

        transport.outboundData = []

        conn.close()

        XCTAssertEqual([], transport.outboundData)

        try! q.step()

        for ch in allocator.channels[1...3] {
            XCTAssert(ch.blockingCloseCalled)
        }

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
    }

    func testServerInitiatedClosing() {
        let (transport, _, _, _) = TestHelper.connectionAfterHandshake()

        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelNumber: 0)

        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelNumber: 0)
    }

}
