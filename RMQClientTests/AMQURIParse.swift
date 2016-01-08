//
//  AMQURIParse.swift
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

import XCTest

class AMQURIParse: XCTestCase {
    
    func testNonAMQPSchemesNotAllowed() {
        do {
            try AMQURI.parse("amqpfoo://dev.rabbitmq.com")
            XCTFail("No error assigned")
        }
        catch let e as NSError {
            XCTAssertEqual(
                "Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK",
                e.localizedDescription
            )
        }
        catch {
            XCTFail("Wrong error")
        }
        
    }
    
    func testHandlesAMQPURIsWithoutPathPart() {
        let val = try! AMQURI.parse("amqp://dev.rabbitmq.com")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("dev.rabbitmq.com", val.host)
        XCTAssertEqual(5672, val.portNumber)
        XCTAssertEqual("amqp", val.scheme)
        XCTAssertFalse(val.isSSL!)
    }
    
    func testHandlesAMQPSURIsWithoutPathPart() {
        let val = try! AMQURI.parse("amqps://dev.rabbitmq.com")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("dev.rabbitmq.com", val.host)
        XCTAssertEqual(5671, val.portNumber)
        XCTAssertEqual("amqps", val.scheme)
        XCTAssertTrue(val.isSSL!)
    }
    
    func testParsesVhostAsEmptyStringWhenPathIsJustASlash() {
        let val = try! AMQURI.parse("amqp://dev.rabbitmq.com/")
        XCTAssertEqual("", val.vhost)
    }
    
    func testPercentEncodedSlashIsJustSlash() {
        let val = try! AMQURI.parse("amqp://dev.rabbitmq.com/%2Fvault")
        XCTAssertEqual("/vault", val.vhost)
    }
    
    func testDoesNotIncludeSlashesWhenNoneAfterFirst() {
        let val = try! AMQURI.parse("amqp://dev.rabbitmq.com/a.path.without.slashes")
        XCTAssertEqual("a.path.without.slashes", val.vhost)
    }
    
    func testSlashesNotAllowedInVhost() {
        do {
            try AMQURI.parse("amqp://dev.rabbitmq.com/a/path/with/slashes")
            XCTFail("No error assigned")
        }
        catch let e as NSError {
            XCTAssertEqual(
                "amqp://dev.rabbitmq.com/a/path/with/slashes has multiple-segment path; please percent-encode any slashes in the vhost name (e.g. /production => %2Fproduction). Learn more at http://bit.ly/amqp-gem-and-connection-uris",
                e.localizedDescription
            )
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    func testParsesUsernameAndPassword() {
        let val = try! AMQURI.parse("amqp://hedgehog:t0ps3kr3t@hub.megacorp.internal")
        XCTAssertEqual("/", val.vhost)
        XCTAssertEqual("hub.megacorp.internal", val.host)
        XCTAssertEqual(5672, val.portNumber)
        XCTAssertEqual("amqp", val.scheme)
        XCTAssertFalse(val.isSSL!)
        XCTAssertEqual("hedgehog", val.username)
        XCTAssertEqual("t0ps3kr3t", val.password)
    }

}
