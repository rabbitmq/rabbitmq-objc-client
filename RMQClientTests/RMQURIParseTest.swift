import XCTest

class RMQURIParseTest: XCTestCase {
    
    func testNonAMQPSchemesNotAllowed() {
        XCTAssertThrowsError(try RMQURI.parse("amqpfoo://dev.rabbitmq.com")) { (error) in
            do {
                XCTAssertEqual(
                    "Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK",
                    (error as NSError).localizedDescription
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
                    "amqp://dev.rabbitmq.com/a/path/with/slashes has multiple-segment path; please percent-encode any slashes in the vhost name (e.g. /production => %2Fproduction). Learn more at http://bit.ly/amqp-gem-and-connection-uris",
                    (error as NSError).localizedDescription
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
