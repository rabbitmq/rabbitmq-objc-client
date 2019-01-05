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

class RMQHTTPParserTest: XCTestCase {
    // swiftlint:disable function_body_length
    func testParseArrayOfConnectionsWithManyItems() {
        let parser = RMQHTTPParser()
        let json = """
                [
                  {
                    "connected_at":1476723031601,
                    "client_properties":{
                      "capabilities":{
                        "publisher_confirms":true,
                        "consumer_cancel_notify":true,
                        "exchange_exchange_bindings":true,
                        "basic.nack":true,
                        "connection.blocked":true,
                        "authentication_failure_close":true
                      },
                      "product":"Bunny",
                      "platform":"ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin17]",
                      "version":"2.5.0",
                      "information":"http://rubybunny.info"
                    },
                    "channel_max":65535,
                    "frame_max":131072,
                    "timeout":60,
                    "vhost":"/",
                    "user":"guest",
                    "protocol":"AMQP 0-9-1",
                    "ssl_hash":null,
                    "ssl_cipher":null,
                    "ssl_key_exchange":null,
                    "ssl_protocol":null,
                    "auth_mechanism":"PLAIN",
                    "peer_cert_validity":null,
                    "peer_cert_issuer":null,
                    "peer_cert_subject":null,
                    "ssl":false,
                    "peer_host":"127.0.0.1",
                    "host":"127.0.0.1",
                    "peer_port":52257,
                    "port":5672,
                    "name":"127.0.0.1:52257 -> 127.0.0.1:5672",
                    "node":"rabbit@localhost",
                    "type":"network",
                    "garbage_collection":{
                      "max_heap_size":0,
                      "min_bin_vheap_size":46422,
                      "min_heap_size":233,
                      "fullsweep_after":65535,
                      "minor_gcs":1
                    },
                    "reductions":6520,
                    "channels":0,
                    "state":"running",
                    "send_pend":0,
                    "send_cnt":3,
                    "recv_cnt":4,
                    "recv_oct_details":{
                      "rate":0.0
                    },
                    "recv_oct":402,
                    "send_oct_details":{
                      "rate":0.0
                    },
                    "send_oct":523,
                    "reductions_details":{
                      "rate":93.2
                    },
                    "reductions":6520
                  },
                  {
                    "connected_at":1476723061830,
                    "client_properties":{
                      "capabilities":{
                        "publisher_confirms":true,
                        "consumer_cancel_notify":true,
                        "exchange_exchange_bindings":true,
                        "basic.nack":true,
                        "connection.blocked":true,
                        "authentication_failure_close":true
                      },
                      "product":"Bunny",
                      "platform":"ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin17]",
                      "version":"2.5.0",
                      "information":"http://rubybunny.info"
                    },
                    "channel_max":65535,
                    "frame_max":131072,
                    "timeout":60,
                    "vhost":"/",
                    "user":"guest",
                    "protocol":"AMQP 0-9-1",
                    "ssl_hash":null,
                    "ssl_cipher":null,
                    "ssl_key_exchange":null,
                    "ssl_protocol":null,
                    "auth_mechanism":"PLAIN",
                    "peer_cert_validity":null,
                    "peer_cert_issuer":null,
                    "peer_cert_subject":null,
                    "ssl":false,
                    "peer_host":"127.0.0.1",
                    "host":"127.0.0.1",
                    "peer_port":52282,
                    "port":5672,
                    "name":"127.0.0.1:52282 -> 127.0.0.1:5672",
                    "node":"rabbit@localhost",
                    "type":"network",
                    "garbage_collection":{
                      "max_heap_size":0,
                      "min_bin_vheap_size":46422,
                      "min_heap_size":233,
                      "fullsweep_after":65535,
                      "minor_gcs":4
                    },
                    "reductions":3594,
                    "channels":0,
                    "state":"running",
                    "send_pend":0,
                    "send_cnt":3,
                    "recv_cnt":3,
                    "recv_oct_details":{
                      "rate":0.0
                    },
                    "recv_oct":394,
                    "send_oct_details":{
                      "rate":0.0
                    },
                    "send_oct":523,
                    "reductions_details":{
                      "rate":0.0
                    }
                  }
                ]
        """
        let connections = parser.connections(json.data(using: String.Encoding.utf8)!)
        XCTAssertEqual("127.0.0.1:52257 -> 127.0.0.1:5672", connections[0].name)
        XCTAssertEqual("127.0.0.1:52282 -> 127.0.0.1:5672", connections[1].name)
    }

}
