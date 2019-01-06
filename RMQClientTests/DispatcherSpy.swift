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

@objc class DispatcherSpy: NSObject, RMQDispatcher {
    var lastSyncMethod: RMQMethod?
    var lastSyncMethodHandler: ((RMQFrameset?) -> Void)?
    var lastBlockingSyncMethod: RMQMethod?
    var syncMethodsSent: [RMQMethod] = []
    var lastAsyncFrameset: RMQFrameset?
    var lastAsyncMethod: RMQMethod?
    var lastBlockingWaitOn: String?
    var activatedWithChannel: RMQChannel?
    weak var activatedWithDelegate: RMQConnectionDelegate?
    var lastFramesetHandled: RMQFrameset?
    var fakeSerialQueue = FakeSerialQueue()
    var disabled = false
    var open = false

    func blockingWait(on method: AnyClass!) {
        lastBlockingWaitOn = method.description()
    }

    func activate(with channel: RMQChannel!, delegate: RMQConnectionDelegate!) {
        activatedWithChannel = channel
        activatedWithDelegate = delegate
        open = true
    }

    func sendAsyncMethod(_ method: RMQMethod!) {
        lastAsyncMethod = method
    }

    func sendAsyncFrameset(_ frameset: RMQFrameset!) {
        lastAsyncFrameset = frameset
    }

    func sendSyncMethod(_ method: RMQMethod!, completionHandler: ((RMQFrameset?) -> Swift.Void)!) {
        syncMethodsSent.append(method)
        lastSyncMethod = method
        lastSyncMethodHandler = completionHandler
    }

    func sendSyncMethod(_ method: RMQMethod!) {
        sendSyncMethod(method) { _ in }
    }

    func sendSyncMethodBlocking(_ method: RMQMethod!) {
        syncMethodsSent.append(method)
        lastBlockingSyncMethod = method
    }

    func handle(_ frameset: RMQFrameset!) {
        lastFramesetHandled = frameset
    }

    func enqueue(_ operation: RMQOperation!) {
        fakeSerialQueue.enqueue(operation)
    }

    func disable() {
        disabled = true
        fakeSerialQueue.suspend()
    }

    func enable() {
        disabled = false
        fakeSerialQueue.resume()
    }

    func isOpen() -> Bool {
        return open
    }

    func wasClosedByServer() -> Bool {
        return lastFramesetHandled?.method.isKind(of: RMQChannelClose.self) ?? false
    }

    func wasClosedExplicitly() -> Bool {
        return lastSyncMethod?.isKind(of: RMQChannelClose.self) ?? false
    }

    // MARK: Helpers

    func step() throws {
        try fakeSerialQueue.step()
    }

    func finish() throws {
        try fakeSerialQueue.finish()
    }

    func pendingItemsCount() -> Int {
        return fakeSerialQueue.pendingItemsCount()
    }

}
