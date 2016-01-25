@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false
    var receivedData: NSData?
    var outboundData: NSData = NSData()

    func connect() {
        connected = true
    }
    func close() {
        connected = false
    }
    func write(data: NSData, onComplete complete: () -> Void) {
        outboundData = data;
        complete()
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        if (receivedData != nil) {
            complete(receivedData!)
        }
    }
    func lastWrite() -> String {
        return String(data: outboundData, encoding: NSASCIIStringEncoding)!
    }
    func receive(data: NSData) {
        receivedData = data
    }
}