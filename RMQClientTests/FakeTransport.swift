@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false

    var myData: NSData = NSData()

    func connect() {
        connected = true
    }
    func close() {
        connected = false
    }
    func write(data: NSData, onComplete complete: () -> Void) {
        myData = data;
        complete()
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        complete(Fixtures().connectionStart())
    }
    func lastWrite() -> String {
        return String(data: myData, encoding: NSASCIIStringEncoding)!
    }
}