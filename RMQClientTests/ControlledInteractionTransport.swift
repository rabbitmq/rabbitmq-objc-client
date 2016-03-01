import XCTest

enum TestDoubleTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

@objc class ControlledInteractionTransport: NSObject, RMQTransport {
    var connected = false
    var outboundData: [NSData] = []
    var callbacks: Array<(NSData) -> Void> = []
    var callbackIndexToRunNext = 0

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
        serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionTune(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionOpenOk(), channelID: 0)
        return self
    }
    func serverSendsData(data: NSData) -> ControlledInteractionTransport {
        if callbacks.isEmpty {
            XCTFail("No read callbacks stored!")
        } else if callbackIndexToRunNext == callbacks.count - 1 {
            callbacks.last!(data)
            callbackIndexToRunNext++
        } else {
            XCTFail("No callbacks left to run! Exhausted \(callbacks.count).")
        }
        return self
    }
    func serverSendsPayload(payload: AMQPayload, channelID: Int) -> ControlledInteractionTransport {
        serverSendsData(AMQFrame(channelID: channelID, payload: payload).amqEncoded())
        return self
    }
    func assertClientSentMethod(amqMethod: AMQMethod, channelID: Int) -> ControlledInteractionTransport {
        if outboundData.isEmpty {
            XCTFail("nothing sent")
        } else {
            let actual = outboundData.last!
            let parser = AMQParser(data: actual)
            let frame = AMQFrame(parser: parser)
            TestHelper.assertEqualBytes(
                AMQFrame(channelID: channelID, payload: amqMethod).amqEncoded(),
                actual,
                "\nExpected:\n\(amqMethod.dynamicType)\nGot:\n\(frame.payload.dynamicType)"
            )
        }
        return self
    }
    func assertClientSentMethods(methods: [AMQMethod], channelID: Int) -> ControlledInteractionTransport {
        if outboundData.isEmpty {
            XCTFail("nothing sent")
        } else {
            let lastIndex = outboundData.count - 1
            let startIndex = lastIndex - methods.count + 1
            let actual = Array(outboundData[startIndex...lastIndex])
            let decoded = outboundData.map { (data) -> String in
                let parser = AMQParser(data: data)
                let frame = AMQFrame(parser: parser)
                let decoded = frame.payload as? AMQMethod
                return "\(decoded?.dynamicType)"
            }
            let expected = methods.map { (method) -> NSData in
                return AMQFrame(channelID: channelID, payload: method).amqEncoded()
            }
            XCTAssertEqual(expected, actual, "\nAll outgoing methods: \(decoded)")
        }
        return self
    }
    func assertClientSentProtocolHeader() -> ControlledInteractionTransport {
        TestHelper.pollUntil { return self.outboundData.count > 0 }
        TestHelper.assertEqualBytes(
            AMQProtocolHeader().amqEncoded(),
            outboundData.last!
        )
        return self
    }
}