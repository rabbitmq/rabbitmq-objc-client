import XCTest

class ConnectionTuningTest: XCTestCase {
    func testUsesClientTuneOptionsWhenServersAreZeroes() {
        let transport = ControlledInteractionTransport()
        let q = connectWithOptions(transport, 12, 10, 9)

        XCTAssertEqual(
            clientTuneOk(
                RMQShort(12), RMQLong(10), RMQShort(9)
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
                RMQShort(12), RMQLong(10), RMQShort(9)
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
                RMQShort(11),  RMQLong(9), RMQShort(8)
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
                RMQShort(11), RMQLong(10), RMQShort(9)
            ),
            negotiatedParamsGivenServerParams(
                transport, q,
                RMQShort(11), RMQLong(10), RMQShort(9)
            )
        )
    }

    func testSetsHalfOfNegotiatedHeartbeatTimeoutAsHeartbeatInterval() {
        let transport = ControlledInteractionTransport()
        let heartbeatSender = HeartbeatSenderSpy()
        let q = connectWithOptions(transport, 1, 1, 100, heartbeatSender: heartbeatSender)
        XCTAssertNil(heartbeatSender.heartbeatIntervalReceived)
        negotiatedParamsGivenServerParams(transport, q,
                                          RMQShort(11), RMQLong(10), RMQShort(0))
        XCTAssertEqual(50, heartbeatSender.heartbeatIntervalReceived)
    }

    // MARK: Helpers

    func connectWithOptions(transport: ControlledInteractionTransport,
                            _ channelMax: Int, _ frameMax: UInt, _ heartbeat: Int,
                              heartbeatSender: RMQHeartbeatSender = HeartbeatSenderSpy()) -> FakeSerialQueue {
        let q = FakeSerialQueue()
        let connection = RMQConnection(
            transport: transport,
            config: ConnectionHelper.connectionConfig(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat),
            handshakeTimeout: 10,
            channelAllocator: ChannelSpyAllocator(),
            frameHandler: FrameHandlerSpy(),
            delegate: nil,
            commandQueue: q,
            waiterFactory: FakeWaiterFactory(),
            heartbeatSender: heartbeatSender
        )
        connection.start()
        try! q.step()
        return q
    }

    func clientTuneOk(channelMax: RMQShort, _ frameMax: RMQLong, _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
        return RMQConnectionTuneOk(channelMax: channelMax, frameMax: frameMax, heartbeat: heartbeat)
    }

    func negotiatedParamsGivenServerParams(transport: ControlledInteractionTransport,
                                           _ q: FakeSerialQueue,
                                             _ channelMax: RMQShort,
                                               _ frameMax: RMQLong,
                                                 _ heartbeat: RMQShort) -> RMQConnectionTuneOk {
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
