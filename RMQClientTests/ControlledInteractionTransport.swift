import XCTest

enum TestDoubleTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
    case ArbitraryError(localizedDescription: String)
}

@objc class ControlledInteractionTransport: NSObject, RMQTransport {
    var connected = false
    var outboundData: [NSData] = []
    var callbacks: Array<(NSData) -> Void> = []
    var callbackIndexToRunNext = 0
    var stubbedToThrowErrorOnWrite: String?

    func connect(onComplete complete: () -> Void) throws {
        connected = true
        complete()
    }
    func close(onClose: () -> Void) {
        connected = false
        onClose()
    }
    func write(data: NSData, onComplete complete: () -> Void) throws {
        if let stubbedError = stubbedToThrowErrorOnWrite {
            throw NSError(domain: "RMQ", code: 0, userInfo: [ NSLocalizedDescriptionKey : stubbedError ])
        } else if (!connected) {
            throw TestDoubleTransportError.NotConnected(localizedDescription: "foo")
        }
        outboundData.append(data)
        complete()
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        callbacks.append(complete)
    }
    func handshake() -> Self {
        serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
        serverSendsPayload(MethodFixtures.connectionTune(), channelNumber: 0)
        serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)
        return self
    }
    func serverSendsData(data: NSData) -> Self {
        if callbacks.isEmpty {
            XCTFail("No read callbacks stored!")
        } else if callbackIndexToRunNext == callbacks.count - 1 {
            callbacks.last!(data)
            callbackIndexToRunNext += 1
        } else {
            XCTFail("No callbacks left to run! Exhausted \(callbacks.count).")
        }
        return self
    }
    func serverSendsPayload(payload: AMQPayload, channelNumber: Int) -> Self {
        serverSendsData(AMQFrame(channelNumber: channelNumber, payload: payload).amqEncoded())
        return self
    }
    func assertClientSentMethod(amqMethod: AMQMethod, channelNumber: Int) -> Self {
        if outboundData.isEmpty {
            XCTFail("nothing sent")
        } else {
            let actual = outboundData.last!
            let parser = AMQParser(data: actual)
            let frame = AMQFrame(parser: parser)
            TestHelper.assertEqualBytes(
                AMQFrame(channelNumber: channelNumber, payload: amqMethod).amqEncoded(),
                actual,
                "\nExpected:\n\(amqMethod.dynamicType)\nGot:\n\(frame.payload.dynamicType)"
            )
        }
        return self
    }
    func assertClientSentMethods(methods: [AMQMethod], channelNumber: Int) -> Self {
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
                return AMQFrame(channelNumber: channelNumber, payload: method).amqEncoded()
            }
            XCTAssertEqual(expected, actual, "\nAll outgoing methods: \(decoded)")
        }
        return self
    }
    func assertClientSentProtocolHeader() -> Self {
        TestHelper.pollUntil { return self.outboundData.count > 0 }
        TestHelper.assertEqualBytes(
            AMQProtocolHeader().amqEncoded(),
            outboundData.last!
        )
        return self
    }
}