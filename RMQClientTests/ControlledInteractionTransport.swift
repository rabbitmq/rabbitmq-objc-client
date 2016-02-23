import XCTest

@objc class ControlledInteractionTransport: NSObject, RMQTransport {
    var connected = false
    var outboundData: [NSData] = []
    var callbacks: Array<(NSData) -> Void> = []

    func connect(onConnect: () -> Void) {
        connected = true
        onConnect()
    }
    func close(onClose: () -> Void) {
        connected = false
        onClose()
    }
    func write(data: NSData, onComplete complete: () -> Void) throws -> RMQTransport {
        if (!connected) {
            throw TestDoubleTransportError.NotConnected(localizedDescription: "foo")
        }
        outboundData.append(data)
        complete()
        return self
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        callbacks.append(complete)
    }
    func assertHandshake() -> ControlledInteractionTransport {
        assertClientSentProtocolHeader()
        serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
        assertClientSentMethod(MethodFixtures.connectionStartOk(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionTune(), channelID: 0)
        assertClientSentMethod(MethodFixtures.connectionTuneOk(), channelID: 0)
        assertClientSentMethod(MethodFixtures.connectionOpen(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionOpenOk(), channelID: 0)
        return self
    }
    func handshake() -> ControlledInteractionTransport {
        serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionTune(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionOpenOk(), channelID: 0)
        outboundData = []
        return self
    }
    func serverSendsData(data: NSData) -> ControlledInteractionTransport {
        if callbacks.isEmpty {
            XCTFail("no read callbacks available")
        } else {
            callbacks.removeAtIndex(0)(data)
        }
        return self
    }
    func serverSendsPayload(payload: AMQPayload, channelID: Int) -> ControlledInteractionTransport {
        serverSendsData(AMQFrame(channelID: channelID, payload: payload).amqEncoded())
        return self
    }
    func assertClientSentMethod(amqMethod: AMQMethod, channelID: Int) -> ControlledInteractionTransport {
        if outboundData.isEmpty {
            XCTFail("nothing sent recently")
        } else {
            let actual = outboundData.removeAtIndex(0)
            let decoder = AMQMethodDecoder(data: actual)
            TestHelper.assertEqualBytes(
                AMQFrame(channelID: channelID, payload: amqMethod).amqEncoded(),
                actual,
                "\nExpected:\n\(amqMethod.dynamicType)\nGot:\n\(decoder.decode().dynamicType)"
            )
        }
        return self
    }
    func assertClientSentFrameset(frameset: AMQFrameset) -> ControlledInteractionTransport {
        if outboundData.isEmpty {
            XCTFail("nothing sent recently")
        } else {
            let actual = outboundData.removeAtIndex(0)
            TestHelper.assertEqualBytes(
                frameset.amqEncoded(),
                actual
            )
        }
        return self
    }
    func assertClientSentProtocolHeader() -> ControlledInteractionTransport {
        TestHelper.assertEqualBytes(
            AMQProtocolHeader().amqEncoded(),
            outboundData.removeAtIndex(0)
        )
        return self
    }
}