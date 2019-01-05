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

enum TestDoubleTransportError: Error {
    case notConnected(localizedDescription: String)
    case arbitraryError(localizedDescription: String)
}

@objc class ControlledInteractionTransport: NSObject, RMQTransport {
    // swiftlint:disable weak_delegate
    var delegate: RMQTransportDelegate?
    var connected = false
    var outboundData: [Data] = []
    var readCallbacks: [(Data) -> Void] = []
    var callbackIndexToRunNext = 0
    var stubbedToThrowErrorOnConnect: String?

    func connect() throws {
        if let stubbedError = stubbedToThrowErrorOnConnect {
            throw NSError(domain: RMQErrorDomain, code: 0, userInfo: [ NSLocalizedDescriptionKey: stubbedError ])
        } else {
            connected = true
        }
    }

    func close() {
        connected = false
        delegate?.transport(self, disconnectedWithError: nil)
    }

    func write(_ data: Data) {
        outboundData.append(data)
    }

    func isConnected() -> Bool {
        return connected
    }

    func readFrame(_ complete: @escaping (Data) -> Void) {
        readCallbacks.append(complete)
    }

    func simulateDisconnect() {
    }

    @discardableResult
    func handshake() -> Self {
        return serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionTune(), channelNumber: 0)
            .serverSendsPayload(MethodFixtures.connectionOpenOk(), channelNumber: 0)
    }

    @discardableResult
    func serverSendsPayload(_ payload: RMQPayload, channelNumber: Int) -> Self {
        return serverSendsData(RMQFrame(channelNumber: channelNumber as NSNumber, payload: payload).amqEncoded())
    }

    @discardableResult
    func serverSendsData(_ data: Data) -> Self {
        if readCallbacks.isEmpty {
            XCTFail("No read callbacks stored for \(decode(data))!")
        } else if callbackIndexToRunNext == readCallbacks.count - 1 {
            readCallbacks.last!(data)
            callbackIndexToRunNext += 1
        } else {
            XCTFail("No read callbacks left to fulfill! Already fulfilled \(readCallbacks.count).")
        }
        return self
    }

    @discardableResult
    func assertClientSentMethod(_ amqMethod: RMQMethod, channelNumber: Int) -> Self {
        if outboundData.isEmpty {
            XCTFail("Nothing sent. Expected \(type(of: amqMethod)).")
        } else {
            let actual = outboundData.last!
            let parser = RMQParser(data: actual)
            let frame = RMQFrame(parser: parser)
            TestHelper.assertEqualBytes(
                RMQFrame(channelNumber: channelNumber as NSNumber, payload: amqMethod).amqEncoded(),
                actual,
                "\nExpected:\n\(type(of: amqMethod))\nGot:\n\(type(of: frame.payload))"
            )
        }
        return self
    }

    func lastSentPayload() -> RMQPayload {
        let actual = outboundData.last!
        let parser = RMQParser(data: actual)
        let frame = RMQFrame(parser: parser)
        return frame.payload
    }

    func assertClientSentMethods(_ methods: [RMQMethod], channelNumber: Int) -> Self {
        if outboundData.isEmpty {
            XCTFail("nothing sent")
        } else {
            let lastIndex = outboundData.count - 1
            let startIndex = lastIndex - methods.count + 1
            let actual = Array(outboundData[startIndex...lastIndex])
            let decoded = outboundData.map { (data) -> String in
                decode(data)
            }
            let expected = methods.map { (method) -> Data in
                return RMQFrame(channelNumber: channelNumber as NSNumber, payload: method).amqEncoded()
            }
            XCTAssertEqual(expected, actual, "\nAll outgoing methods: \(decoded)")
        }
        return self
    }

    func assertClientSentProtocolHeader() -> Self {
        TestHelper.pollUntil { return self.outboundData.count > 0 }
        TestHelper.assertEqualBytes(
            RMQProtocolHeader().amqEncoded(),
            outboundData.last!
        )
        return self
    }

    func decode(_ data: Data) -> String {
        let parser = RMQParser(data: data)
        let frame = RMQFrame(parser: parser)
        let decoded = frame.payload as? RMQMethod
        return "\(type(of: decoded))"
    }
}
