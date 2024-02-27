// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 2.0 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2022 VMware, Inc. or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v2.0:
//
// ---------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2007-2022 VMware, Inc. or its affiliates.  All rights reserved.
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

import Foundation
import XCTest

// see https://github.com/rabbitmq/rabbitmq-objc-client/blob/master/CONTRIBUTING.md
// to set up your system for running integration tests
class CertificateAuthenticationIntegrationTest: XCTestCase {
    #if RUN_TLS_TESTS
    func testConnectsViaTLS() {
        let semaphore  = DispatchSemaphore(value: 0)
        let tlsOptions = RMQTLSOptions(peerName: "localhost",
                                       verifyPeer: false,
                                       pkcs12: nil,
                                       pkcs12Password: "")
        let transport  = RMQTCPSocketTransport(host: "localhost",
                                               port: 5671,
                                               tlsOptions: tlsOptions,
                                               connectTimeout: 15,
                                               readTimeout: 30,
                                               writeTimeout: 30)
        try! transport.connect()
        transport.write(RMQProtocolHeader().amqEncoded())

        var receivedData: Data?
        transport.readFrame { data in
            receivedData = data
            semaphore.signal()
        }

        XCTAssertEqual(.success, semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(5)),
                       "Timed out waiting for read")
        let parser = RMQParser(data: receivedData!)
        XCTAssert(RMQFrame(parser: parser).payload.isKind(of: RMQConnectionStart.self))

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func testConnectsViaTLSWithClientCert() {
        let semaphore = DispatchSemaphore(value: 0)
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: fixtureClientCertificatePKCS12() as Data,
            pkcs12Password: CertificateFixtures.password
        )
        let transport = RMQTCPSocketTransport(host: "localhost",
                                              port: 5671,
                                              tlsOptions: tlsOptions,
                                              connectTimeout: 15,
                                              readTimeout: 30,
                                              writeTimeout: 30)
        try! transport.connect()
        transport.write(RMQProtocolHeader().amqEncoded())

        var receivedData: Data?
        transport.readFrame { data in
            receivedData = data
            semaphore.signal()
        }

        XCTAssertEqual(.success, semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(5)),
                       "Timed out waiting for read")
        let parser = RMQParser(data: receivedData!)
        XCTAssert(RMQFrame(parser: parser).payload.isKind(of: RMQConnectionStart.self))

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func testThrowsWhenTLSPasswordIncorrect() {
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: fixtureClientCertificatePKCS12() as Data,
            pkcs12Password: "incorrect-password"
        )
        let transport = RMQTCPSocketTransport(host: "127.0.0.1",
                                              port: 5671,
                                              tlsOptions: tlsOptions,
                                              connectTimeout: 15,
                                              readTimeout: 30,
                                              writeTimeout: 30)

        #if os(iOS)
        XCTAssertThrowsError(try transport.connect())
        #endif
    }

    func testSubscribeWithClientCertificateAuthentication() {
        let delegate = RMQConnectionDelegateLogger()
        let noisyHeartbeats = 1
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: fixtureClientCertificatePKCS12() as Data,
            pkcs12Password: CertificateFixtures.password
        )
        let conn = RMQConnection(uri: "amqps://localhost",
                                 tlsOptions: tlsOptions,
                                 delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let semaphore = DispatchSemaphore(value: 0)
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.autoDelete, .exclusive])

        var delivered: RMQMessage?

        q.subscribe(withAckMode: [.manual]) { message in
            delivered = message
            ch.ack(message.deliveryTag)
            semaphore.signal()
        }

        let body = "my message".data(using: String.Encoding.utf8)!

        q.publish(body)

        XCTAssertEqual(.success,
                       semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for message")

        XCTAssertEqual(1, delivered!.deliveryTag)
        XCTAssertEqual(body, delivered!.body)
    }
    #endif

    //
    // Implementation
    //

    fileprivate func fixtureClientCertificatePKCS12() -> Data {
        do {
            return try CertificateFixtures.guestBunniesP12()
        } catch {
            fatalError("Failed to load the fixture client certificate")
        }
    }
}
