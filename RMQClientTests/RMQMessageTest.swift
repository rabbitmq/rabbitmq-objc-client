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

import XCTest

class RMQMessageTest: XCTestCase {

    func testPropertiesHaveAssociatedGetters() {
        let date = Date()
        var props: [RMQValue] = []
        props.append(RMQBasicAppId("my app ID"))
        props.append(RMQBasicContentType("some/contenttype"))
        props.append(RMQBasicCorrelationId("my correlation ID"))
        props.append(RMQBasicHeaders(["some": RMQLongstr("header")]))
        props.append(RMQBasicMessageId("my message ID"))
        props.append(RMQBasicType("my type"))
        props.append(RMQBasicPriority(9))
        props.append(RMQBasicReplyTo("my.sender"))
        props.append(RMQBasicTimestamp(date))

        let m = RMQMessage(body: "my message".data(using: String.Encoding.utf8),
                           consumerTag: "ctag",
                           deliveryTag: 1,
                           redelivered: false,
                           exchangeName: "my exchange",
                           routingKey: "my routing key",
                           properties: (props as! [RMQValue & RMQBasicValue]))

        let expectedHeaders: [String: NSObject] = ["some": RMQLongstr("header")]
        XCTAssertEqual("my app ID", m?.appID())
        XCTAssertEqual("some/contenttype", m?.contentType())
        XCTAssertEqual("my correlation ID", m?.correlationID())
        XCTAssertEqual(expectedHeaders, (m?.headers())!)
        XCTAssertEqual("my message ID", m?.messageID())
        XCTAssertEqual("my type", m?.messageType())
        XCTAssertEqual(9, m?.priority())
        XCTAssertEqual("my.sender", m?.replyTo())
        XCTAssertEqual(date, m?.timestamp())
    }

}
