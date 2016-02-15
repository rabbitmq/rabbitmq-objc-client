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
    func handshake() -> ControlledInteractionTransport {
        return clientSendsProtocolHeader()
            .serverSendsMethod(MethodFixtures.connectionStart(), channelID: 0)
            .assertClientSendsMethod(MethodFixtures.connectionStartOk(), channelID: 0)
            .serverSendsMethod(MethodFixtures.connectionTune(), channelID: 0)
            .assertClientSendsMethod(MethodFixtures.connectionTuneOk(), channelID: 0)
            .assertClientSendsMethod(MethodFixtures.connectionOpen(), channelID: 0)
            .serverSendsMethod(MethodFixtures.connectionOpenOk(), channelID: 0)
    }
    func serverSendsData(data: NSData) -> ControlledInteractionTransport {
        if callbacks.isEmpty {
            XCTFail("no read callbacks available")
        } else {
            callbacks.removeAtIndex(0)(data)
        }
        return self
    }
    func serverSendsMethod(amqMethod: AMQMethod, channelID: Int) -> ControlledInteractionTransport {
        let encoder = AMQEncoder()
        serverSendsData(encoder.encodeMethod(amqMethod, channelID: channelID))
        return self
    }
    func assertClientSendsMethod(amqMethod: AMQMethod, channelID: Int) -> ControlledInteractionTransport {
        if outboundData.isEmpty {
            XCTFail("nothing sent recently")
        } else {
            let actual = outboundData.removeAtIndex(0)
            TestHelper.assertEqualBytes(
                AMQEncoder().encodeMethod(amqMethod, channelID: channelID),
                actual,
                "Didn't send \(amqMethod)\n\nSent: \(actual)"
            )
        }
        return self
    }
    func clientSendsProtocolHeader() -> ControlledInteractionTransport {
        TestHelper.assertEqualBytes(
            AMQProtocolHeader().amqEncoded(),
            outboundData.removeAtIndex(0)
        )
        return self
    }
}