import XCTest

enum FakeTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false
    var receivedData: [NSData] = []
    var outboundData: NSData = NSData()

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
        outboundData = data;
        complete()
        return self
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        if (receivedData.isEmpty) {
            XCTFail("You need to call receive() before readFrame() is called")
        } else{
            complete(receivedData.removeAtIndex(0))
        }
    }
    func lastWrite() -> NSData {
        return outboundData
    }
    func receive(data: NSData) -> FakeTransport {
        receivedData.append(data)
        return self
    }
}