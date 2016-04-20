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

    func testTransportDelegateWriteErrorsAreTransformedIntoConnectionDelegateErrors() {
        let (transport, q, conn, connDelegate) = TestHelper.connectionAfterHandshake()
        transport.stubbedToProduceErrorOnWrite = "foo"

        conn.start()
        q.finish()

        XCTAssertEqual("foo", connDelegate.lastWriteError!.localizedDescription)
    }

    func testTransportDelegateDisconnectErrorsAreTransformedIntoConnectionDelegateErrors() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "foo"])

        conn.transport(nil, disconnectedWithError: e)

        XCTAssertEqual("foo", delegate.lastDisconnectError!.localizedDescription)
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

    func testClientInitiatedClosingDuringHandshakeWaitsForHandshakeToComplete() {
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
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: ConnectionDelegateSpy(),
            delegateQueue: q.dispatchQueue,
            networkQueue: q.dispatchQueue
        )
        conn.start()

        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionTune(), channelNumber: 0)

        q.finish()

        conn.close()

        transport.assertClientSentMethod(MethodFixtures.connectionOpen(), channelNumber: 0)
        transport.serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)

        q.finish()

        transport.assertClientSentMethod(MethodFixtures.connectionClose(), channelNumber: 0)

        XCTAssert(transport.isConnected())
        transport.serverSendsPayload(MethodFixtures.connectionCloseOk(), channelNumber: 0)
        XCTAssertFalse(transport.isConnected())
    }

    func testServerInitiatedClosing() {
        let transport = ControlledInteractionTransport()
        let q = QueueHelper()
        TestHelper.startedConnection(transport,
                                     delegateQueue: q.dispatchQueue,
                                     networkQueue: q.dispatchQueue)
        q.finish()
        transport.handshake()

        transport.serverSendsPayload(MethodFixtures.connectionClose(), channelNumber: 0)

        q.finish()
        XCTAssertFalse(transport.isConnected())
        transport.assertClientSentMethod(MethodFixtures.connectionCloseOk(), channelNumber: 0)
    }

    func testSendFramesetUsesNetworkQueue() {
        let (transport, q, conn, _) = TestHelper.connectionAfterHandshake()
        let frameset = AMQFrameset(channelNumber: 42, method: MethodFixtures.queueDeclare("da-club"))
        conn.sendFrameset(frameset)

        XCTAssertNotEqual(frameset.amqEncoded(), transport.outboundData.last)
        q.finish()
        XCTAssertEqual(frameset.amqEncoded(), transport.outboundData.last)
    }

}
