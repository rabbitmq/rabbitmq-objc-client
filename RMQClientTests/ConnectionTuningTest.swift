import XCTest

class ConnectionTuningTest: XCTestCase {
    func startedConnection(transport: ControlledInteractionTransport, channelMax: Int, frameMax: Int, heartbeat: Int) -> RMQConnection {
        let connection = RMQConnection(
            user: "foo",
            password: "bar",
            vhost: "baz",
            transport: transport,
            idAllocator: RMQChannelIDAllocator(),
            channelMax: channelMax,
            frameMax: frameMax,
            heartbeat: heartbeat
            ).start()
        transport.serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
        return connection
    }

    func testUsesClientTuneOptionsWhenServersAreZeroes() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport, channelMax: 12, frameMax: 10, heartbeat: 9)

        let serverTune = AMQProtocolConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(0), heartbeat: AMQShort(0))
        transport.serverSendsPayload(serverTune, channelID: 0)

        let decoder = AMQMethodDecoder(data: transport.outboundData[transport.outboundData.count - 2])
        let actualTuneOk = decoder.decode() as! AMQProtocolConnectionTuneOk

        let expectedClientTuneOk = AMQProtocolConnectionTuneOk(channelMax: AMQShort(12), frameMax: AMQLong(10), heartbeat: AMQShort(9))
        XCTAssertEqual(expectedClientTuneOk, actualTuneOk)
    }

    func testUsesServerTuneOptionsWhenClientsAreZeroes() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport, channelMax: 0, frameMax: 0, heartbeat: 0)

        let serverTune = AMQProtocolConnectionTune(channelMax: AMQShort(123), frameMax: AMQLong(456), heartbeat: AMQShort(789))
        let expectedClientTuneOk = AMQProtocolConnectionTuneOk(channelMax: AMQShort(123), frameMax: AMQLong(456), heartbeat: AMQShort(789))
        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
            .serverSendsPayload(serverTune, channelID: 0)

        let decoder = AMQMethodDecoder(data: transport.outboundData[transport.outboundData.count - 2])
        let actualTuneOk = decoder.decode() as! AMQProtocolConnectionTuneOk

        XCTAssertEqual(expectedClientTuneOk, actualTuneOk)
    }

    func testUsesClientTuneOptionsWhenServersAreHigher() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport, channelMax: 3, frameMax: 2, heartbeat: 1)

        let serverTune = AMQProtocolConnectionTune(channelMax: AMQShort(4), frameMax: AMQLong(3), heartbeat: AMQShort(2))
        let expectedClientTuneOk = AMQProtocolConnectionTuneOk(channelMax: AMQShort(3), frameMax: AMQLong(2), heartbeat: AMQShort(1))
        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
            .serverSendsPayload(serverTune, channelID: 0)

        let decoder = AMQMethodDecoder(data: transport.outboundData[transport.outboundData.count - 2])
        let actualTuneOk = decoder.decode() as! AMQProtocolConnectionTuneOk

        XCTAssertEqual(expectedClientTuneOk, actualTuneOk)
    }

    func testUsesServerTuneOptionsWhenClientsAreHigher() {
        let transport = ControlledInteractionTransport()
        startedConnection(transport, channelMax: 4, frameMax: 3, heartbeat: 2)

        let serverTune = AMQProtocolConnectionTune(channelMax: AMQShort(3), frameMax: AMQLong(2), heartbeat: AMQShort(1))
        let expectedClientTuneOk = AMQProtocolConnectionTuneOk(channelMax: AMQShort(3), frameMax: AMQLong(2), heartbeat: AMQShort(1))
        transport
            .serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
            .serverSendsPayload(serverTune, channelID: 0)

        let decoder = AMQMethodDecoder(data: transport.outboundData[transport.outboundData.count - 2])
        let actualTuneOk = decoder.decode() as! AMQProtocolConnectionTuneOk

        XCTAssertEqual(expectedClientTuneOk, actualTuneOk)
    }
}
