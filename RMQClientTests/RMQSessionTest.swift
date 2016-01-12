import XCTest

class FakeTransport: RMQTransport {
    var myData: NSData = NSData()
    
    @objc func connect() {
        
    }
    @objc func close() {
        
    }
    @objc func write(data: NSData) {
        myData = data
    }
    @objc func isOpen() -> Bool {
        return false
    }
    
    func read() -> String {
        return String(data: myData, encoding: NSUTF8StringEncoding)!
    }
}

class RMQSessionTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        srandom(UInt32(time(nil)))
    }
    
    func testSendsPreambleToTransport() {
        let transport: FakeTransport = FakeTransport()
        let conn = RMQConnection(user: "foo", password: "bar", vhost: "baz", transport: transport)
        
        conn.start()
        
        XCTAssertEqual("AMQP0091", transport.read())
    }
    
}
