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
import CocoaAsyncSocket

class RMQTCPSocketTransportTest: XCTestCase {
    static let noTLS = RMQTLSOptions.fromURI("amqp://localhost")
    let noTLS = RMQTLSOptions.fromURI("amqp://localhost")
    let noOpSocketConfigurator = { (_socket: GCDAsyncSocket?) -> Void in
      // no-op
    }

    func testObeysContract() {
        RMQTransportContract(createTransport()).check()
    }

    func testReadsFrameEndsInZeroSizedFrames() {
        let callbacks = [:] as NSMutableDictionary
        let transport = RMQTCPSocketTransport(host: "127.0.0.1",
                                              port: 5672,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks,
                                              socketConfigurator: noOpSocketConfigurator,
                                              connectTimeout: 15.0,
                                              readTimeout: 30.0,
                                              writeTimeout: 30.0)
        var receivedData: Data?
        transport.readFrame { data in
            receivedData = data
        }
        let heartbeat = RMQHeartbeat().amqEncoded()
        let header = heartbeat.subdata(in: 0..<7)
        let endByte = heartbeat.subdata(in: 7..<8)
        transport.socket(GCDAsyncSocket(), didRead: header, withTag: callbacks.allKeys.first as! Int)
        transport.socket(GCDAsyncSocket(), didRead: endByte, withTag: callbacks.allKeys.first as! Int)

        XCTAssertEqual(header, receivedData)

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func testIsNotConnectedWhenSocketDisconnectedOutsideOfCloseBlock() {
        let transport = createTransport()
        let error = NSError(domain: "", code: 0, userInfo: [:])
        transport.socketDidDisconnect(GCDAsyncSocket(), withError: error)

        XCTAssertFalse(transport.isConnected())

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func testCallbacksAreRemovedAfterUse() {
        let callbacks = [:] as NSMutableDictionary
        let transport = RMQTCPSocketTransport(host: "127.0.0.1", port: 5672,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks,
                                              socketConfigurator: noOpSocketConfigurator,
                                              connectTimeout: 15.0,
                                              readTimeout: 30.0,
                                              writeTimeout: 30.0)

        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { return transport.isConnected() }, "couldn't connect")

        transport.write(RMQProtocolHeader().amqEncoded())
        transport.readFrame { _ in
            transport.close()
        }

        XCTAssert(TestHelper.pollUntil { return !transport.isConnected() }, "couldn't exercise all callbacks")
        XCTAssertEqual(0, callbacks.count)
    }

    func testSendsErrorToDelegateWhenConnectionTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        let delegate = TransportDelegateSpy()
        let transport = RMQTCPSocketTransport(host: "127.0.0.1", port: 123456,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks,
                                              socketConfigurator: noOpSocketConfigurator,
                                              connectTimeout: 15.0,
                                              readTimeout: 30.0,
                                              writeTimeout: 30.0)

        transport.delegate = delegate
        try! transport.connect()

        TestHelper.pollUntil { delegate.lastDisconnectError != nil }

        XCTAssertEqual(NSPOSIXErrorDomain, (delegate.lastDisconnectError! as NSError).domain)

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func testExtendsReadWhenReadTimesOut() {
        let callbacks = RMQSynchronizedMutableDictionary()
        let transport = RMQTCPSocketTransport(host: "127.0.0.1", port: 123456,
                                              tlsOptions: noTLS,
                                              callbackStorage: callbacks,
                                              socketConfigurator: noOpSocketConfigurator,
                                              connectTimeout: 15.0,
                                              readTimeout: 30.0,
                                              writeTimeout: 30.0)
        let timeoutExtension = transport.socket(GCDAsyncSocket(), shouldTimeoutReadWithTag: 123,
                                                elapsed: 123, bytesDone: 999)
        XCTAssert(timeoutExtension > 0)
    }

    func testConnectsUsingIPv4Address() {
        doTestConnectsToHostWithoutTLS(host: "127.0.0.1")
    }

    func testConnectsUsingHostname() {
        doTestConnectsToHostWithoutTLS(host: "localhost")
    }

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

    func testSimulatedDisconnectCausesTransportToReportAsDisconnected() {
        let transport = RMQTCPSocketTransport(host: "127.0.0.1",
                                              port: 5672,
                                              tlsOptions: noTLS,
                                              connectTimeout: 15,
                                              readTimeout: 30,
                                              writeTimeout: 30)
        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { transport.isConnected() })
        transport.simulateDisconnect()
        XCTAssert(TestHelper.pollUntil { !transport.isConnected() })
    }

    func testSimulatedDisconnectSendsErrorToDelegate() {
        let transport = RMQTCPSocketTransport(host: "127.0.0.1",
                                              port: 5672,
                                              tlsOptions: noTLS,
                                              connectTimeout: 15,
                                              readTimeout: 30,
                                              writeTimeout: 30)
        let delegate = TransportDelegateSpy()
        transport.delegate = delegate
        try! transport.connect()
        XCTAssert(TestHelper.pollUntil { transport.isConnected() })
        transport.write(RMQProtocolHeader().amqEncoded())
        transport.simulateDisconnect()

        XCTAssert(TestHelper.pollUntil {
            delegate.lastDisconnectError?._code == RMQError.simulatedDisconnect.rawValue
        })

        if(transport.isConnected()) {
            transport.close()
        }
    }

    func createTransport() -> RMQTCPSocketTransport {
        return RMQTCPSocketTransport(host: "127.0.0.1",
                                     port: 5672,
                                     tlsOptions: noTLS,
                                     connectTimeout: 15,
                                     readTimeout: 30,
                                     writeTimeout: 30)
    }

    func doTestConnectsToHostWithoutTLS(host: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let transport = RMQTCPSocketTransport(host: host,
                                              port: 5672,
                                              tlsOptions: noTLS,
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

    fileprivate func fixtureClientCertificatePKCS12() -> Data {
        do {
            return try CertificateFixtures.guestBunniesP12()
        } catch {
            fatalError("Failed to load the fixture client certificate")
        }
    }
}
