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
        catch let error as NSError {
            XCTAssertEqual(
                "Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK",
                error.localizedDescription
            )
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
}
