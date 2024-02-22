//
//  ConnectionUpdateSecretTest.swift
//  RMQClientTests
//
//  Created by Andrew Urban on 22.02.2024.
//  Copyright © 2024 VMware. All rights reserved.
//

import XCTest

final class ConnectionUpdateSecretTest: XCTestCase {
    
    func testSendsUpdateSecretMethod() {
        let (transport, q, conn, _) = ConnectionWithFakesHelper.connectionAfterHandshake()
        
        let secret = "someSecret"
        let reason = "ObjC client needs it"

        conn.updateSecret(secret)

        try? q.step()
        
        transport.assertClientSentMethod(MethodFixtures.connectionUpdateSecret(secret, reason: reason), channelNumber: 0)
    }

}
