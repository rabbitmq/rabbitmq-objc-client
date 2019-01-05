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

class RMQTLSOptionsTest: XCTestCase {

    func testAuthMechanismIsPlainWhenNoPKCS12Provided() {
        let opts = RMQTLSOptions(peerName: "yokelboast",
                                 verifyPeer: true,
                                 pkcs12: nil,
                                 pkcs12Password: "foo")
        XCTAssertEqual("PLAIN", opts.authMechanism())
    }

    func testAuthMechanismIsExternalWhenPKCS12Provided() {
        let opts = RMQTLSOptions(peerName: "soakalmost",
                                 verifyPeer: true,
                                 pkcs12: fixtureClientCertificatePKCS12() as Data,
                                 pkcs12Password: "bar")
        XCTAssertEqual("EXTERNAL", opts.authMechanism())
    }

    func testDelegatesCertificates() {
        let opts = RMQTLSOptions(peerName: "localghost",
                                 verifyPeer: true,
                                 pkcs12: fixtureClientCertificatePKCS12() as Data,
                                 pkcs12Password: CertificateFixtures.password)
        XCTAssertEqual(1, try! opts.certificates().count)
    }

    func testAmqpsUriIsParsedWithVerifyPeerEnabled() {
        let opts = RMQTLSOptions.fromURI("amqps://user:password@hosty.foo")
        XCTAssert(opts.useTLS)
        XCTAssertEqual("PLAIN", opts.authMechanism())
        XCTAssert(opts.verifyPeer)
        XCTAssertEqual("hosty.foo", opts.peerName)
    }

    func testAmqpsUriWithVerifyPeerDisabled() {
        let opts = RMQTLSOptions.fromURI("amqps://user:password@localhost", verifyPeer: false)
        XCTAssertFalse(opts.verifyPeer)
    }

    func testAmqpUriIsParsedAsNonTLS() {
        let opts = RMQTLSOptions.fromURI("amqp://user:password@hosty.foo")
        XCTAssertEqual("PLAIN", opts.authMechanism())
        XCTAssertFalse(opts.useTLS)
    }

    fileprivate func fixtureClientCertificatePKCS12() -> Data {
        do {
            return try CertificateFixtures.guestBunniesP12()
        } catch {
            fatalError("Failed to load the fixture client certificate")
        }
    }
}
