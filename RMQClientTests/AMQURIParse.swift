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
            try AMQURI.parse("http://dev.rabbitmq.com")
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
        XCTAssertEqual("dev.rabbitmq.com", val.host)
        XCTAssertEqual(5672, val.portNumber)
        XCTAssertEqual("amqp", val.scheme)
        XCTAssertFalse(val.isSSL!)
    }
    
}
