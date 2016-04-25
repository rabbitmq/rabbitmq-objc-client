import XCTest

class ConnectionTuningTest: XCTestCase {
    let zeroHeartbeatUntilHeartbeatsAreHandled = RMQShort(0)

    func testUsesClientTuneOptionsWhenServersAreZeroes() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 12, 10, 9)

        XCTAssertEqual(
            clientTuneOk(
                RMQShort(12), RMQLong(10), zeroHeartbeatUntilHeartbeatsAreHandled
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(0),  RMQLong(0), RMQShort(0)
            )
        )
    }

    func testUsesServerTuneOptionsWhenClientsAreZeroes() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 0, 0, 0)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(12), RMQLong(10), zeroHeartbeatUntilHeartbeatsAreHandled
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(12), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testUsesClientTuneOptionsWhenServersAreHigher() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 11, 9, 8)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(11),  RMQLong(9), zeroHeartbeatUntilHeartbeatsAreHandled
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(12), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testUsesServerTuneOptionsWhenClientsAreHigher() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 12, 11, 10)
        XCTAssertEqual(
            clientTuneOk(
                RMQShort(11), RMQLong(10), zeroHeartbeatUntilHeartbeatsAreHandled
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(11), RMQLong(10), RMQShort(9)
            )
        )
    }

    // MARK: Helpers

    func connectWithOptions(transport: ControlledInteractionTransport, _ channelMax: Int, _ frameMax: Int, _ heartbeat: Int) -> FakeSerialQueue {
        let q = FakeSerialQueue()
        let allocator = RMQMultipleChannelAllocator(channelSyncTimeout: 2)
        let connection = RMQConnection(
            transport: transport,
            user: "foo",
            password: "bar",
            vhost: "baz",
            channelMax: channelMax,
            frameMax: frameMax,
            heartbeat: heartbeat,
            handshakeTimeout: 10,
            channelAllocator: allocator,
            frameHandler: allocator,
            delegate: nil,
            delegateQueue: dispatch_get_main_queue(),
            networkQueue: q,
            waiterFactory: FakeWaiterFactory()
        )
        connection.start()
        try! q.step()
        return q
    }

    func clientTuneOk(channelMax: RMQShort, _ frameMax: RMQLong, _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
        return RMQConnectionTuneOk(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat)
    }

    func negotiatedParamsGivenServerParams(transport: ControlledInteractionTransport, _ q: FakeSerialQueue, _ channelMax: RMQShort, _ frameMax: RMQLong, _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
        let tune = RMQConnectionTune(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat)

        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
            .serverSendsPayload(tune, channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)

        let parser = RMQParser(data: transport.outboundData[transport.outboundData.count - 2])
        let frame = RMQFrame(parser: parser)
        return frame.payload as! RMQConnectionTuneOk
    }
}
