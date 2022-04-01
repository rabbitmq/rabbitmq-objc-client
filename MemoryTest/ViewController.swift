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
import UIKit
import RMQClient
class ViewController: UIViewController {
    let amqp = ""

    var connection: RMQConnection?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connection = RMQConnection()
         connection?.start({
             print("Connected")
         })
    }
    
    @IBAction func clearConnection() {
        connection?.close()
        connection = nil
        print("CLOSED")
        connection = RMQConnection()
         connection?.start({
             print("Connected")
         })
    }


}

extension ViewController: RMQConnectionDelegate {
    /// @brief Called when a socket cannot be opened, or when AMQP handshaking times out for some reason.
    func connection(_ connection: RMQConnection!, failedToConnectWithError error: Error!) {
        print(self)
        print("RABBIT: failedToConnectWithError")
    }

    /// @brief Called when a connection disconnects for any reason
    func connection(_ connection: RMQConnection!, disconnectedWithError error: Error!) {
        print(self)
        print("RABBIT: disconnectedWithError")
    }

    /// @brief Called before the configured http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> sleep.
    func willStartRecovery(with connection: RMQConnection!) {
        print(self)
        print("RABBIT: willStartRecovery")
    }

    /// @brief Called after the configured http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> sleep.
    func startingRecovery(with connection: RMQConnection!) {
        print(self)
        print("RABBIT: startingRecovery")
    }

    /*!
     * @brief Called when http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> has succeeded.
     * @param RMQConnection the connection instance that was recovered.
     */
    func recoveredConnection(_ connection: RMQConnection!) {
        print(self)
        print("RABBIT: recoveredConnection")

    }

    /// @brief Called with any channel-level AMQP exception.
    func channel(_ channel: RMQChannel!, error: Error!) {
        print(self)
        print("RABBIT: Channel Error")
    }
}
