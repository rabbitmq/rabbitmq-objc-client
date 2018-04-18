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
        /// a server can never connect
        let uri = "amqp://127.0.0.1:5555"
        let conn = RMQConnection(uri: uri, delegate: RMQConnectionDelegateLogger())
        conn.start()
        conn.blockingClose()
    }
}
