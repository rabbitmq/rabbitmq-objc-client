import XCTest

enum TestDoubleTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

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
    func readFrameSwift() -> Promise<NSData> {
        let (promise, fulfill, _) = Promise<NSData>.pendingPromise()
        callbacks.append(fulfill)
        return promise
    }
    func readFrame() -> AnyPromise {
        return AnyPromise(bound: readFrameSwift())
    }
    func handshake() -> ControlledInteractionTransport {
        serverSendsPayload(MethodFixtures.connectionStart(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionTune(), channelID: 0)
        serverSendsPayload(MethodFixtures.connectionOpenOk(), channelID: 0)
        return self
    }
    func serverSendsData(data: NSData) -> ControlledInteractionTransport {
        if callbacks.isEmpty {
            XCTFail("no read callbacks available")
        } else {
            callbacks.last!(data)
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
            let decoder = AMQMethodDecoder(data: actual)
            TestHelper.assertEqualBytes(
                AMQFrame(channelID: channelID, payload: amqMethod).amqEncoded(),
                actual,
                "\nExpected:\n\(amqMethod.dynamicType)\nGot:\n\(decoder.decode().dynamicType)"
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
                let decoder = AMQMethodDecoder(data: data)
                let decoded = decoder.decode() as? AMQMethod
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