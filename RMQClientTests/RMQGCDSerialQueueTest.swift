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

class RMQGCDSerialQueueTest: XCTestCase {

    func testAsyncEnqueue() {
        let q = RMQGCDSerialQueue(name: "async enqueue test")
        let semaphore = DispatchSemaphore(value: 0)
        q?.enqueue { semaphore.signal() }

        XCTAssertEqual(
            .success,
            semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
            "Timed out waiting for queued work"
        )
    }

    func testSyncEnqueue() {
        let q = RMQGCDSerialQueue(name: "sync enqueue test")
        var foo = 1
        q?.enqueue { foo += 1 }
        q?.blockingEnqueue { foo += 2 }

        XCTAssertEqual(4, foo)
    }

    func testSuspendAndResume() {
        let q = RMQGCDSerialQueue(name: "suspend and resume test")
        var foo = 1
        q?.suspend()
        q?.enqueue { foo += 1 }
        TestHelper.run(0.2)
        XCTAssertEqual(1, foo)
        q?.resume()
        q?.blockingEnqueue {}
        XCTAssertEqual(2, foo)
    }

    func testCannotOverResumeOrSuspend() {
        let q = RMQGCDSerialQueue(name: "over-resume test")
        q?.resume()
        q?.resume()
        q?.suspend()
        q?.suspend()
        q?.resume()

        var foo: String?
        q?.blockingEnqueue {
            foo = "bar"
        }
        XCTAssertEqual("bar", foo)
    }

    func testDelayedEnqueue() {
        let q = RMQGCDSerialQueue(name: "delay test")
        let semaphore = DispatchSemaphore(value: 0)
        var items: [String] = []
        q?.delayed(by: 0.01) {
            items.append("delayed")
            semaphore.signal()
        }
        q?.enqueue {
            items.append("enqueued")
        }

        XCTAssertEqual(.success, semaphore.wait(timeout: TestHelper.dispatchTimeFromNow(2)),
                       "Timed out waiting for queue to finish")
        XCTAssertEqual(["enqueued", "delayed"], items)
    }

}
