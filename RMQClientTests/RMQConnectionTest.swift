import XCTest

@objc class FakeTransport: NSObject, RMQTransport {
    var myData: NSData = NSData()
    
    func connect() {
        
    }
    func close() {
        
    }
    func write(data: NSData) {
        myData = data
    }
    func isOpen() -> Bool {
        return false
    }
    func read() -> NSData {
        return NSData()
    }
    func spy() -> String {
        return String(data: myData, encoding: NSASCIIStringEncoding)!
    }
}

class RMQConnectionTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        srandom(UInt32(time(nil)))
    }
    
    func testSendsPreambleToTransport() {
        let transport: FakeTransport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        conn.start()
        
        XCTAssertEqual("AMQP\0\0\t\u{01}", transport.spy())
    }
    
}
