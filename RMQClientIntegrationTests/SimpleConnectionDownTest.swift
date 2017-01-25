//
//  SimpleConnectionDownTest.swift
//  RMQClient
//
//  Created by Владимир Березкин on 25/01/2017.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import XCTest

class SimpleConnectionDownTest: XCTestCase {
    
    func testConnectionDown() {
        let uri = "amqp://127.0.0.1:5555"   //  not real server
        let conn = RMQConnection(uri: uri, delegate: nil)
        conn.start()
        conn.blockingClose()
    }
}
