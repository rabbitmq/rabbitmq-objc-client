import XCTest

enum FakeTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false
    var inboundData: [NSData] = []
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
            throw FakeTransportError.NotConnected(localizedDescription: "foo")
        }
        outboundData.append(data)
        complete()
        return self
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        if (inboundData.isEmpty) {
            callbacks.append(complete)
        } else {
            complete(inboundData.removeAtIndex(0))
        }
    }
    func sentFrame(index: Int) -> NSData {
        return outboundData[index]
    }
    func lastFrameIndex() -> Int {
        return outboundData.endIndex - 1
    }
    func serverWillReplyWith(data: NSData) -> FakeTransport {
        inboundData.append(data)
        return self
    }
    func serverRepliesWith(data: NSData) -> FakeTransport {
        callbacks.removeAtIndex(0)(data)
        return self
    }
    func mustHaveSent(amqMethod: AMQMethod, channelID: Int, frame: Int) -> FakeTransport {
        TestHelper.assertEqualBytes(AMQEncoder().encodeMethod(amqMethod, channelID: channelID), actual: self.sentFrame(frame))
        return self
    }
}