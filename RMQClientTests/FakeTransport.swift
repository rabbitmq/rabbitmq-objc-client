import XCTest

enum FakeTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false
    var receivedData: [NSData] = []
    var outboundData: [NSData] = []

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
        if (receivedData.isEmpty) {
            XCTFail("You need to set up an incoming frame with receive()\n\nOutgoing messages: \(outboundData)")
        } else{
            complete(receivedData.removeAtIndex(0))
        }
    }
    func sentFrame(index: Int) -> NSData {
        return outboundData[index]
    }
    func lastFrame() -> NSData {
        return outboundData[outboundData.endIndex - 1]
    }
    func receive(data: NSData) -> FakeTransport {
        receivedData.append(data)
        return self
    }
}