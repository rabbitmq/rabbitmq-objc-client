import XCTest

class RMQConnectionTest: XCTestCase {

    func testImmediateConnectionErrorIsSentToDelegate() {
        let transport = ControlledInteractionTransport()
        transport.stubbedToThrowErrorOnConnect = "bad connection"
        let delegate = ConnectionDelegateSpy()
        let queueHelper = QueueHelper()
        let allocator = RMQMultipleChannelAllocator()
        let conn = RMQConnection(
            transport: transport,
            user: "foo",
            password: "bar",
            vhost: "",
            channelMax: 123,
            frameMax: 321,
            heartbeat: 10,
            syncTimeout: 1,
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

    func testClientInitiatedClosing() {
        let (transport, q, conn, _) = TestHelper.connectionAfterHandshake()

        conn.close()

        q.finish()

        transport.assertClientSentMethod(
            AMQConnectionClose(
                replyCode: AMQShort(200),
                replyText: AMQShortstr("Goodbye"),
                classId: AMQShort(0),
                methodId: AMQShort(0)
            ),
            channelNumber: 0
        )
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

    func testDeliveryWithZeroBodySizeDoesNotCauseBodyFrameRead() {
        let (transport, _, _, _) = TestHelper.connectionAfterHandshake()

        let deliver = AMQFrame(channelNumber: 42, payload: MethodFixtures.basicDeliver())
        let header = AMQFrame(channelNumber: 42, payload: AMQContentHeader(classID: 60, bodySize: 0, properties: []))

        transport.serverSendsData(deliver.amqEncoded())

        let before = transport.readCallbacks.count
        transport.serverSendsData(header.amqEncoded())
        let after = transport.readCallbacks.count

        XCTAssertEqual(after, before)
    }

}
