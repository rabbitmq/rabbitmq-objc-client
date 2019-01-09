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

class ChannelAllocationTest: XCTestCase {
    let allocationsPerQueue = 30000

    func allocateAll(_ allocator: RMQChannelAllocator) {
        for _ in 1...RMQChannelMaxDefault {
            allocator.allocate()
        }
    }

    func testChannelGetsNegativeOneChannelNumberWhenOutOfChannelNumbers() {
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        allocateAll(allocator!)
        XCTAssertEqual(-1, allocator?.allocate().channelNumber)
    }

    func testChannelGetsAFreedChannelNumberIfOtherwiseOutOfChannelNumbers() {
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        allocateAll(allocator!)
        allocator?.releaseChannelNumber(2)
        XCTAssertEqual(2, allocator?.allocate().channelNumber)
        XCTAssertEqual(-1, allocator?.allocate().channelNumber)
    }

    func testAllocatedChannelsCanBeRead() {
        let allocator = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        _ = allocator?.allocate()
        _ = allocator?.allocate()
        _ = allocator?.allocate()
        _ = allocator?.allocate()
        allocator?.releaseChannelNumber(1)
        XCTAssertEqual([2, 3], (allocator?.allocatedUserChannels().map { $0.channelNumber })!)
    }

    func testNumbersAreNotDoubleAllocated() {
        let allocator   = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        var channelSet1 = Set<NSNumber>()
        var channelSet2 = Set<NSNumber>()
        var channelSet3 = Set<NSNumber>()
        let group       = DispatchGroup()
        let queues      = [
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        ]

        queues[0].async(group: group) {
            for _ in 1...self.allocationsPerQueue {
                channelSet1.insert((allocator?.allocate().channelNumber)!)
            }
        }

        queues[1].async(group: group) {
            for _ in 1...self.allocationsPerQueue {
                channelSet2.insert((allocator?.allocate().channelNumber)!)
            }
        }

        queues[2].async(group: group) {
            for _ in 1...self.allocationsPerQueue {
                channelSet3.insert((allocator?.allocate().channelNumber)!)
            }
        }

        XCTAssertEqual(.success, group.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                                            "Timed out waiting for allocations")

        let channelSets                    = [channelSet1, channelSet2, channelSet3]
        let expectedUniqueUnallocatedCount = channelSets.reduce(0, sumUnallocated)
        let total                          = channelSets.reduce(0, {$0 + $1.count})

        XCTAssertEqual(RMQChannelMaxDefault + expectedUniqueUnallocatedCount, total)
    }

    func testChannelsAreReleasedWithThreadSafety() {
        let allocator   = RMQMultipleChannelAllocator(maxCapacity: 127, channelSyncTimeout: 2)
        let group       = DispatchGroup()
        let queues      = [
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        ]
        allocateAll(allocator!)

        queues[0].async(group: group) {
            for n in 1...RMQChannelMaxDefault {
                allocator?.releaseChannelNumber(n as NSNumber)
            }
        }

        queues[1].async(group: group) {
            for n in 1...RMQChannelMaxDefault {
                allocator?.releaseChannelNumber(n as NSNumber)
            }
        }

        queues[2].async(group: group) {
            for n in 1...RMQChannelMaxDefault {
                allocator?.releaseChannelNumber(n as NSNumber)
            }
        }

        XCTAssertEqual(.success, group.wait(timeout: TestHelper.dispatchTimeFromNow(10)),
                                            "Timed out waiting for releases")
        XCTAssertEqual(1, allocator?.allocate().channelNumber)
    }

    func sumUnallocated(_ accumulator: Int, current: Set<NSNumber>) -> Int {
        return accumulator + (current.count == self.allocationsPerQueue ? 0 : 1)
    }

}
