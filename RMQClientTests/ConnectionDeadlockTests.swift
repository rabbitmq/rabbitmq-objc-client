//
//  ConnectionDeadlockTests.swift
//  RMQClientTests
//
//  Created by Li Jiantang on 18/04/2018.
//  Copyright © 2018 Pivotal. All rights reserved.
//

import XCTest

class ConnectionDeadlockTests: XCTestCase {
    
    func testCallingCloseWhileDisconnected() {
        
        let expection = expectation(description: "Should not encounter deadlock.")
        
        DispatchQueue(label: "test.queue").async {
            /// a server can never connect
            let uri = "amqp://127.0.0.1:5555"
            let conn = RMQConnection(uri: uri, delegate: RMQConnectionDelegateLogger())
            conn.start()
            conn.blockingClose()
            
            /// if no deadlock, this should be called
            expection.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error, "Should have no error")
        }
    }
}
