import XCTest

class IntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func XtestIntegration() {
        let conn = RMQSession()
        conn.start()
        
        let ch = conn.createChannel()
        let q = ch.queue("rmqclient.examples.hello_world", autoDelete: true)
        let x = ch.defaultExchange()
        
        let expectation = self.expectationWithDescription("subscription data received")
        
        let expectedInfo = ["consumer_tag": "foo"]
        let expectedMeta = ["foo": "bar"]
        let expectedPayload = ["baz": "qux"]
        
        q.subscribe { (info, meta, p) -> Void in
            if NSDictionary(dictionary: info).isEqualToDictionary(expectedInfo) &&
                NSDictionary(dictionary: meta).isEqualToDictionary(expectedMeta) &&
                NSDictionary(dictionary: p).isEqualToDictionary(expectedPayload) {
                    expectation.fulfill()
            } else {
                XCTFail("subscribe response unexpected")
            }
            
        }
        
        x.publish("Hello!", routingKey: q.name)
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
}
