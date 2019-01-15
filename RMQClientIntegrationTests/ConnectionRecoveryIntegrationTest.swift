// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 1.1 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2019 Pivotal Software, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v1.1:
//
// ---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is RabbitMQ
//
// The Initial Developer of the Original Code is Pivotal Software, Inc.
// All Rights Reserved.
//
// Alternatively, the contents of this file may be used under the terms
// of the Apache Standard license (the "ASL License"), in which case the
// provisions of the ASL License are applicable instead of those
// above. If you wish to allow use of your version of this file only
// under the terms of the ASL License and not to allow others to use
// your version of this file under the MPL, indicate your decision by
// deleting the provisions above and replace them with the notice and
// other provisions required by the ASL License. If you do not delete
// the provisions above, a recipient may use your version of this file
// under either the MPL or the ASL License.
// ---------------------------------------------------------------------------

import XCTest

enum RecoveryTestError: Error {
    case timeOutWaitingForConnectionCountToDrop
}

// swiftlint:disable function_body_length
class ConnectionRecoveryIntegrationTest: XCTestCase {
    let plainEndpoint = IntegrationHelper.defaultEndpoint
    let httpAPIClient = RMQHTTP.withTestEndpoint()

    func testRecoversFromSocketDisconnect() {
        let recoveryInterval = 2
        let recoveryTimeout: TimeInterval = 30
        let semaphoreTimeout: Double = 30
        let confirmationTimeout = 10
        let delegate = ConnectionDelegateSpy()

        let tlsOptions = RMQTLSOptions.fromURI(plainEndpoint)
        let transport = RMQTCPSocketTransport(host: "127.0.0.1",
                                              port: 5672,
                                              tlsOptions: tlsOptions,
                                              connectTimeout: 15,
                                              readTimeout: 30,
                                              writeTimeout: 30)

        let conn = ConnectionHelper.makeConnection(recoveryInterval: recoveryInterval,
                                                   transport: transport, delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let q = ch.queue("", options: [.exclusive], arguments: ["x-max-length": RMQShort(3)])
        let ex1 = ch.direct("foo", options: [.autoDelete])
        let ex2 = ch.direct("bar", options: [.autoDelete])
        let consumerSemaphore = DispatchSemaphore(value: 0)
        let confirmSemaphore = DispatchSemaphore(value: 0)

        ex2.bind(ex1)
        q.bind(ex2)

        var messages: [RMQMessage] = []
        let consumer = q.subscribe({ m in
            messages.append(m)
            consumerSemaphore.signal()
        })

        ch.confirmSelect()

        ex1.publish("before close".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(.success, consumerSemaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        transport.simulateDisconnect()

        XCTAssert(TestHelper.pollUntil(recoveryTimeout) { delegate.recoveredConnection != nil },
                  "Didn't finish recovery")

        q.publish("after close 1".data(using: String.Encoding.utf8)!)
        _ = consumerSemaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex1.publish("after close 2".data(using: String.Encoding.utf8)!)
        _ = consumerSemaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        var acks: Set<NSNumber>?
        var nacks: Set<NSNumber>?
        ch.afterConfirmed(confirmationTimeout as NSNumber) { (a, n) in
            acks = a
            nacks = n
            confirmSemaphore.signal()
        }

        XCTAssertEqual(3, messages.count)
        XCTAssertEqual("before close".data(using: String.Encoding.utf8), messages[0].body)
        XCTAssertEqual("after close 1".data(using: String.Encoding.utf8), messages[1].body)
        XCTAssertEqual("after close 2".data(using: String.Encoding.utf8), messages[2].body)

        XCTAssertEqual(.success, confirmSemaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout)))
        XCTAssertEqual(acks!.union(nacks!), [1, 2, 3],
                       "Didn't receive acks or nacks for publications")

        // test recovery of queue arguments - in this case, x-max-length
        consumer.cancel()
        q.publish("4".data(using: String.Encoding.utf8)!)
        q.publish("5".data(using: String.Encoding.utf8)!)
        q.publish("6".data(using: String.Encoding.utf8)!)
        q.publish("7".data(using: String.Encoding.utf8)!)

        var messagesPostCancel: [RMQMessage] = []
        q.subscribe(handler: { m in
            messagesPostCancel.append(m)
            consumerSemaphore.signal()
        })

        for _ in 5...7 {
            XCTAssertEqual(.success, consumerSemaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout)))
        }
        XCTAssertEqual("5".data(using: String.Encoding.utf8), messagesPostCancel[0].body)
        XCTAssertEqual("6".data(using: String.Encoding.utf8), messagesPostCancel[1].body)
        XCTAssertEqual("7".data(using: String.Encoding.utf8), messagesPostCancel[2].body)
    }

    func testReenablesConsumersOnEachRecoveryFromConnectionClose() {
        let recoveryInterval = 2
        let semaphoreTimeout: Double = 30
        let delegate = ConnectionDelegateSpy()

        let conn = RMQConnection(uri: plainEndpoint,
                                 tlsOptions: RMQTLSOptions.fromURI(plainEndpoint),
                                 channelMax: RMQChannelMaxDefault as NSNumber,
                                 frameMax: RMQFrameMax as NSNumber,
                                 heartbeat: 10,
                                 connectTimeout: 15,
                                 readTimeout: 30,
                                 writeTimeout: 30,
                                 syncTimeout: 10,
                                 delegate: delegate,
                                 delegateQueue: DispatchQueue.main,
                                 recoverAfter: recoveryInterval as NSNumber,
                                 recoveryAttempts: 5,
                                 recoverFromConnectionClose: true)
        conn.start()
        defer { conn.blockingClose() }
        let ch = conn.createChannel()
        ch.confirmSelect()
        let q = ch.queue("", options: [.autoDelete, .exclusive])
        let ex = ch.direct("foo", options: [.autoDelete])
        let semaphore = DispatchSemaphore(value: 0)
        var messages: [RMQMessage] = []

        q.bind(ex)

        q.subscribe(handler: { m in
            messages.append(m)
            semaphore.signal()
        })

        ex.publish("before close".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(.success, semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout)),
                       "Timed out waiting for message")

        try! closeAllConnections()

        XCTAssert(TestHelper.pollUntil(30) { self.connections().count >= 1 },
                  "Didn't finish recovery the first time")

        q.publish("after close 1".data(using: String.Encoding.utf8)!)
        _ = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 2".data(using: String.Encoding.utf8)!)
        _ = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual("before close".data(using: String.Encoding.utf8), messages[0].body)
        XCTAssertEqual("after close 1".data(using: String.Encoding.utf8), messages[1].body)
        XCTAssertEqual("after close 2".data(using: String.Encoding.utf8), messages[2].body)

        try! closeAllConnections()

        XCTAssert(TestHelper.pollUntil(30) { self.connections().count >= 1 },
                  "Didn't finish recovery the second time")

        q.publish("after close 3".data(using: String.Encoding.utf8)!)
        _ = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))
        ex.publish("after close 4".data(using: String.Encoding.utf8)!)
        _ = semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(semaphoreTimeout))

        XCTAssertEqual("before close".data(using: String.Encoding.utf8), messages[0].body)
        XCTAssertEqual("after close 1".data(using: String.Encoding.utf8), messages[1].body)
        XCTAssertEqual("after close 2".data(using: String.Encoding.utf8), messages[2].body)
        XCTAssertEqual("after close 3".data(using: String.Encoding.utf8), messages[3].body)
        XCTAssertEqual("after close 4".data(using: String.Encoding.utf8), messages[4].body)
    }

    fileprivate func connections() -> [RMQHTTPConnection] {
        return RMQHTTPParser().connections(httpAPIClient.get("/connections"))
    }

    fileprivate func closeAllConnections() throws {
        let conns = connections()

        for conn in conns {
            let escapedName = conn.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let path = "/connections/\(escapedName)"

            httpAPIClient.delete(path)
        }

        if (!TestHelper.pollUntil(30) { self.connections().count == 0 }) {
            throw RecoveryTestError.timeOutWaitingForConnectionCountToDrop
        }
    }

}
