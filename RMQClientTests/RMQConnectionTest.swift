import XCTest

class RMQConnectionTest: XCTestCase {

    func testImmediateConnectionErrorIsSentToDelegate() {
        let transport = ControlledInteractionTransport()
        transport.stubbedToThrowErrorOnConnect = "bad connection"
        let delegate = ConnectionDelegateSpy()
        let queueHelper = QueueHelper()
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
            delegateQueue: queueHelper.dispatchQueue,
            networkQueue: queueHelper.dispatchQueue
        )
        conn.start()

        XCTAssertNil(delegate.lastConnectionError)
        queueHelper.finish()
        XCTAssertEqual("bad connection", delegate.lastConnectionError!.localizedDescription)
    }

    func testErrorSentToDelegateOnHandshakeTimeout() {
        let transport = ControlledInteractionTransport()
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 10)
        let delegate = ConnectionDelegateSpy()
        let q = QueueHelper()
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
            delegateQueue: q.dispatchQueue,
            networkQueue: q.dispatchQueue
        )
        conn.start()
        q.finish()

        XCTAssertEqual("Handshake timed out.", delegate.lastConnectionError?.localizedDescription)
    }

    func testTransportDelegateWriteErrorsAreTransformedIntoConnectionDelegateErrors() {
        let transport = ControlledInteractionTransport()
        let q = QueueHelper()
        let delegate = ConnectionDelegateSpy()
        TestHelper.startedConnection(transport,
                                     delegateQueue: q.dispatchQueue,
                                     networkQueue: q.dispatchQueue,
                                     delegate: delegate)
        transport.stubbedToProduceErrorOnWrite = "fail please"
        TestHelper.handshakeAsync(transport, q: q)

        XCTAssertEqual("fail please", delegate.lastWriteError!.localizedDescription)
    }

    func testTransportDelegateDisconnectErrorsAreTransformedIntoConnectionDelegateErrors() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
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
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        conn.transport(nil, disconnectedWithError: nil)

        XCTAssertNil(delegate.lastDisconnectError)
        XCTAssertTrue(delegate.disconnectCalled)
    }

    func testClientInitiatedClosingAfterHandshake() {
        let (transport, q, conn, _) = TestHelper.connectionAfterHandshake()

        conn.close()

        q.finish()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testBlockingCloseWaitsOnQueue() {
        let (transport, q, conn, _) = TestHelper.connectionAfterHandshake()
        q.resume()

        conn.blockingClose()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())

        q.suspend()
    }

    func testClientInitiatedClosingWaitsForHandshakeToComplete() {
        let transport = ControlledInteractionTransport()
        let q = QueueHelper()
        let tuneOk = MethodFixtures.connectionTuneOk()
        let conn = RMQConnection(
            transport: transport,
            user: "",
            password: "",
            vhost: "",
            channelMax: tuneOk.channelMax.integerValue,
            frameMax: tuneOk.frameMax.integerValue,
            heartbeat: tuneOk.heartbeat.integerValue,
            handshakeTimeout: 10,
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            delegateQueue: q.dispatchQueue,
            networkQueue: q.dispatchQueue
        )
        conn.start()
        conn.close()

        TestHelper.handshakeAsync(transport, q: q)

        transport.assertClientSentMethods([MethodFixtures.connectionOpen(), MethodFixtures.connectionClose()],
                                          channelNumber: 0)
        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testClientInitiatedClosingWaitsForChannelsToCloseBeforeSendingClose() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let q = QueueHelper()
        let conn = RMQConnection(
            transport: transport,
            user: "",
            password: "",
            vhost: "",
            channelMax: 4,
            frameMax: 5,
            heartbeat: 6,
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            delegateQueue: q.dispatchQueue,
            networkQueue: q.dispatchQueue
        )
        conn.start()
        TestHelper.handshakeAsync(transport, q: q)

        conn.createChannel()
        conn.createChannel()
        conn.createChannel()
        q.finish()

        transport.outboundData = []

        conn.close()

        XCTAssertEqual([], transport.outboundData)

        q.finish()

        for ch in allocator.channels[1...3] {
            XCTAssert(ch.blockingCloseCalled)
        }

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)
    }

    func testServerInitiatedClosing() {
        let (transport, q, _, _) = TestHelper.connectionAfterHandshake()

        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelNumber: 0)

        q.finish()
        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelNumber: 0)
    }

}
