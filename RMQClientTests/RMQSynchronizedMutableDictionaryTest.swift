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

class RMQSynchronizedMutableDictionaryTest: XCTestCase {

    func testSingleThreadedExample() {
        let sharedDictionary = RMQSynchronizedMutableDictionary()

        sharedDictionary[1] = "sandwich"
        sharedDictionary["meat"] = "prosciutto"
        sharedDictionary[3] = "pastrami"

        let actual1: String = sharedDictionary[1] as! String
        XCTAssertEqual("sandwich", actual1)
        let actual2: String = sharedDictionary["meat"] as! String
        XCTAssertEqual("prosciutto", actual2)
        let actual3: String = sharedDictionary[3] as! String
        XCTAssertEqual("pastrami", actual3)

        sharedDictionary.removeObject(forKey: "meat")
        let f = sharedDictionary["meat"] as! String?
        XCTAssertNil(f)

        XCTAssertEqual(2, sharedDictionary.count)
    }

    func testMultiThreadedWriting() {
        let dictGroup = DispatchGroup()

        let sharedDictionary = RMQSynchronizedMutableDictionary()
        var values: [String] = []

        for _ in 1...3000 {
            values.append(ProcessInfo.processInfo.globallyUniqueString)
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async(group: dictGroup) {
            for n in 0...999 {
                sharedDictionary[n] = values[n]
            }
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async(group: dictGroup) {
            for n in 1000...1999 {
                sharedDictionary[n] = values[n]
            }
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(group: dictGroup) {
            for n in 2000...2999 {
                sharedDictionary[n] = values[n]
            }
        }

        _ = dictGroup.wait(timeout: DispatchTime.distantFuture)

        for n in 0...2999 {
            let actual: String = sharedDictionary[n] as! String
            XCTAssertEqual(values[n], actual)
        }
    }

    func testMultiThreadedReading() {
        let dictGroup = DispatchGroup()

        let source = RMQSynchronizedMutableDictionary()
        var dest1: [Int: String] = [:]
        var dest2: [Int: String] = [:]
        var dest3: [Int: String] = [:]

        for n in 0...2999 {
            source[n] = ProcessInfo.processInfo.globallyUniqueString
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async(group: dictGroup) {
            for n in 0...999 {
                let obj: String = source[n] as! String
                dest1[n] = obj
            }
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async(group: dictGroup) {
            for n in 1000...1999 {
                let obj: String = source[n] as! String
                dest2[n] = obj
            }
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(group: dictGroup) {
            for n in 2000...2999 {
                let obj: String = source[n] as! String
                dest3[n] = obj
            }
        }

        _ = dictGroup.wait(timeout: DispatchTime.distantFuture)

        var final: [Int: String] = [:]
        for (k, v) in dest1 { final[k] = v }
        for (k, v) in dest2 { final[k] = v }
        for (k, v) in dest3 { final[k] = v }

        for n in 0...2999 {
            let sourceValue: String = source[n] as! String
            XCTAssertEqual(sourceValue, final[n])
        }
    }

}
