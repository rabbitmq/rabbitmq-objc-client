// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 1.1 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2016 Pivotal Software, Inc.
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

class RMQHTTPParserTest: XCTestCase {

    func testParseArrayOfConnectionsWithOneItem() {
        let parser = RMQHTTPParser()
        let connections = parser.connections("[{\"recv_oct\":393,\"recv_oct_details\":{\"rate\":0.0},\"send_oct\":523,\"send_oct_details\":{\"rate\":0.0},\"recv_cnt\":4,\"send_cnt\":3,\"send_pend\":0,\"state\":\"running\",\"channels\":0,\"type\":\"network\",\"node\":\"rabbit@localhost\",\"name\":\"127.0.0.1:53089 -> 127.0.0.1:5672\",\"port\":5672,\"peer_port\":53089,\"host\":\"127.0.0.1\",\"peer_host\":\"127.0.0.1\",\"ssl\":false,\"peer_cert_subject\":null,\"peer_cert_issuer\":null,\"peer_cert_validity\":null,\"auth_mechanism\":\"PLAIN\",\"ssl_protocol\":null,\"ssl_key_exchange\":null,\"ssl_cipher\":null,\"ssl_hash\":null,\"protocol\":\"AMQP 0-9-1\",\"user\":\"guest\",\"vhost\":\"/\",\"timeout\":60,\"frame_max\":131072,\"channel_max\":65535,\"client_properties\":{\"capabilities\":{\"publisher_confirms\":true,\"consumer_cancel_notify\":true,\"exchange_exchange_bindings\":true,\"basic.nack\":true,\"connection.blocked\":true,\"authentication_failure_close\":true},\"product\":\"Bunny\",\"platform\":\"ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]\",\"version\":\"2.2.2\",\"information\":\"http://rubybunny.info\"},\"connected_at\":1462958634765}]".dataUsingEncoding(NSUTF8StringEncoding)!)
        XCTAssertEqual("127.0.0.1:53089 -> 127.0.0.1:5672", connections[0].name)
    }

}
