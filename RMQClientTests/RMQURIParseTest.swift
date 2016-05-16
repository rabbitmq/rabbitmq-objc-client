import XCTest

class RMQURIParseTest: XCTestCase {
    
    func testNonAMQPSchemesNotAllowed() {
        XCTAssertThrowsError(try RMQURI.parse("amqpfoo://dev.rabbitmq.com")) { error in
            do {
                XCTAssertEqual(
                    RMQError.InvalidScheme.rawValue,
                    (error as NSError).code
                )
            }
        }
    }
    
    func testHandlesAMQPURIsWithoutPathPart() {
        let val = try! RMQURI.parse("amqp://dev.rabbitmq.com")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("dev.rabbitmq.com", val.host)
        XCTAssertEqual(5672, val.portNumber)
        XCTAssertEqual("amqp", val.scheme)
        XCTAssertFalse(val.isTLS)
    }
    
    func testHandlesAMQPSURIsWithoutPathPart() {
        let val = try! RMQURI.parse("amqps://dev.rabbitmq.com")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("dev.rabbitmq.com", val.host)
        XCTAssertEqual(5671, val.portNumber)
        XCTAssertEqual("amqps", val.scheme)
        XCTAssertTrue(val.isTLS)
    }
    
    func testParsesVhostAsEmptyStringWhenPathIsJustASlash() {
        let val = try! RMQURI.parse("amqp://dev.rabbitmq.com/")
        XCTAssertEqual("", val.vhost)
    }
    
    func testPercentEncodedSlashIsJustSlash() {
        let val = try! RMQURI.parse("amqp://dev.rabbitmq.com/%2Fvault")
        XCTAssertEqual("/vault", val.vhost)
    }
    
    func testDoesNotIncludeSlashesWhenNoneAfterFirst() {
        let val = try! RMQURI.parse("amqp://dev.rabbitmq.com/a.path.without.slashes")
        XCTAssertEqual("a.path.without.slashes", val.vhost)
    }
    
    func testSlashesNotAllowedInVhost() {
        XCTAssertThrowsError(try RMQURI.parse("amqp://dev.rabbitmq.com/a/path/with/slashes")) { (error) in
            do {
                XCTAssertEqual(
                    RMQError.InvalidPath.rawValue,
                    (error as NSError).code
                )
            }
        }
    }
    
    func testParsesUsernameAndPassword() {
        let val = try! RMQURI.parse("amqp://hedgehog:t0ps3kr3t@hub.megacorp.internal")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("hub.megacorp.internal", val.host)
        XCTAssertEqual(5672, val.portNumber)
        XCTAssertEqual("amqp", val.scheme)
        XCTAssertFalse(val.isTLS)
        XCTAssertEqual("hedgehog", val.username)
        XCTAssertEqual("t0ps3kr3t", val.password)
    }

}
