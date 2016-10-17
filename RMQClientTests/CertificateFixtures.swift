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

class CertificateFixtures {
    static func guestBunniesP12() -> Data {
        let p12str = "MIIJMQIBAzCCCPcGCSqGSIb3DQEHAaCCCOgEggjkMIII4DCCA5cGCSqGSIb3" +
            "DQEHBqCCA4gwggOEAgEAMIIDfQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYw" +
            "DgQIgf7ZYIumTakCAggAgIIDULaDpO3AHKfCspu7cx/52dE5DZ6HVHXuSFVL" +
            "/jc1dR9saZpP9rcdyxc6EUiu+KiKS93ZPmp1UekI3dd4se7JJWDQjrEYMhkP" +
            "2MTV/hTZYcmP6iPjSAHEEc094L79ufA1EBYeKjGrzdVg16eBu0YSUN1Ix0Fb" +
            "z0RX1mUmtmGUgbR9KDpwDhKX1lX0Hhm5+w8c0bcNsCltZ2b0qJeyZjnvciDx" +
            "kfXoAmMxpWWds4UXXJHLPjRIC3klvKo3AeZL7p4pO1qyThDWlQ9iLczCyOnr" +
            "envu/UIRBgLG+7Xcg11AdOX2WmU4oS84bDeXCdlx+ObkyKqpMZn+wQ+ZIETD" +
            "1ljn0gxHZAMk/i6L6Uev62vvWEfN12wc1zb+jGXq0eNmbnWgg0zWE8dZQMDe" +
            "dv8kNThvSHMGsXG25SR0csrm97i1gm7uH0kv5XVjJVfZgYjlLUj5oRahdw4U" +
            "3i3TlRGQ5cHI6b6zTj6jqHIqQgK0GS+EVbs4QPJ8J5IlVUUeS4tAOOLHMuMu" +
            "LKMmNhMgn0iXVtcIIzMUBUuj/RLxge8Z0Se52gTpomwVJFdylQjPDxF5UzAx" +
            "Z40Ta3QCuXQl01War6lFU3lAEc9JyWiLn5SumAxG5ZPmNHeqGnvAYxT7z90V" +
            "xumcwJ6Wn8b1VsCXdcdG3VQ3i/KCJ27+SIQ2n1OSsl+QJIrJV5ZDy8pqlJlH" +
            "b6iWmlHu8Dv/0P4iQqu4qTuwIxfP/c28/QWvpq4jgXrTckIIKZObkix6KYzU" +
            "5l101jn0+wljwXBkxyIYDrb4w7OL4GvTeNI0g+U2CPL/sOuoxqcOyNOziHym" +
            "tS09wAPWFdbI4jaFHAXSh2/dznstURWQUu9QJDdCJ0tvcF9DDyh+pY9WbO9h" +
            "9mB4UJx9YpNi7PwiaNFPyfNLLJgJIBNfv99eNkLK+hcvFJxAipDfpG/PNMBB" +
            "G0DcJT8uy452cfLArHiyzVYFzPNuYaWaaJ/dUTQtoQuEU4nIW9l5D5m1PXOC" +
            "yAdXFea9IUtCPTQjVjjHqZ5ChK67VMZ8YounxyJBEraBdBM4ujcMyxgKvzRG" +
            "mskwWAOJF9h4Iwbzi2mYKRjlHg4pwVSFaXwJepFI7iGgj/rgMhjKwigm1BPg" +
            "30TV4jjMR+KvMd9wMIIFQQYJKoZIhvcNAQcBoIIFMgSCBS4wggUqMIIFJgYL" +
            "KoZIhvcNAQwKAQKgggTuMIIE6jAcBgoqhkiG9w0BDAEDMA4ECLmj4RiPSJIT" +
            "AgIIAASCBMgedD5xqFWqk4FtCx/iSFCO3AKOzA3QUL/PnBn1I7sdwxWfvvl+" +
            "hradw0iXllY0p1xmWG5u5A1ERL/9NLvaB7PZizWs4k+3YBeBeNxuC6skCJJ7" +
            "I8GQ/mlw/0C2ZqFbPMhB4XvXetmlO65nE9sSg3X7YY0Yko/XAJjFYvJjnf36" +
            "1vCydDmWtydoC4KUQ4Ce2hj/B1t0nrQObpdHC4aUDumteiUglmYtVO3KXEB9" +
            "do4kAvyh0FOtRlgm5Oaor2gavABWad1hzD3yBAEAHEObl9iFPz4RgCbjbACs" +
            "6NeQP71dWbbt7WzVhvIqEiC5xgYbXzJXd/T8vGQYvM7SMct0JRXxpAOv+PzU" +
            "YCRRJQJbQ3MgwBxIlpkNfnnYSZh7rZZTwN1/IlGJ8zuK9AueKKiX2Tl6R26L" +
            "/2KnM7Sqte91uCFO4sOn2MZGAiHElRb5QIP6VXF/jtUsCqU2CuTtuyATxSUW" +
            "l+L0dv0VVGmsNmqfCoW7WvhHlydx/RiO0teyXC5jSTqHCZnSoobcCboyxeSW" +
            "7L7bjDjuG71C7m2DddfhDyDd/hEeV9lKkHvD5rq1uoULf6BYrr/YiCeY065b" +
            "MNX6GB/1felaYVlxZsECQhFQw46rRrORruMYkNBotThhnG+CKOKEdjWl/ap+" +
            "x7f6WKXlmnccXM8AXLaZxtx1B5+ENfBjY8oVjKQwvjPlITcyHqhHY2bbUoWr" +
            "VD5cd+N+2fRRxtFlS+A9q4TIPQwvJEuqMwFxXdyO7QmdHTmdC1WiOqDT41+T" +
            "lv0oYmYyvc5hRYmIrwcnt3DZsBK1pzxZL1M9IK0UedUYfn/hVLwtUgXkcQcE" +
            "V7MNfsczkVNEPMmcUsrHS/jAPyvXp1OVUWwrKUx/5lELLNmOmDwUzm5h5uBO" +
            "O8Mu3gi9VLjdQSQzKnBMxmCZmT+iY+HbGI0qzta3Ox63bZRN8rbG9WaZ/fbU" +
            "4c9mhm7r23vGqxLYoixg6PVFSvi3aaDGlRk8jgCpA12SOLU8l8rF2dHc2g03" +
            "Ve6nX+RdeOdFPquq0yKxMPbz5VpFO4dcEvj10DVNm6wZXrXJs/JT6LAJF0/h" +
            "vIrygREjeza3gEW7TxTkwgGJidBvK37E0NxoV7RF/5po5qjVtOrFsZy7kswS" +
            "i8tMa7Gm51AAmb27VHwjV/0DAQ12MCSduaMzX2vMn1brK2NpzXVjmT2HdK5x" +
            "O/Siq4/M2D52BBxbPpSOVgyspW8/RRRb5yDQ8zNtp8U0H367tcAPbb712xvD" +
            "Ae9ZLsR8ZrXW8c3xB/9Mna0ynYVDfO37wjICnP8W57Y70LWDYno84suU7VvI" +
            "J/oDpaAw/uQ0//qrd6S/J20cTXnxjsLcM1sCPvIWcK3t8soLr34ZGq570Bex" +
            "ryePUExGFq7ZIN29F+nEvDJ48uWtT2B8nxCglb4DsHD+H/jC1O9qtoxD450Z" +
            "XyLrXERlPR8exHyG1X7OpaflH+EylupNaBJU1QxkWBPbgdg3/ek9y/wzsdma" +
            "oXk9bqjP508YiU5esd+q3KntHcvtq+j67SupLFugj05mwp7LLb6PwZuoVwHk" +
            "5QErhhKj04DOgf9wH5t4dPidNODfv0vzyJ/b9/7442O1w7mQfgYz9GuSM02P" +
            "fQVWzJMzYrZPILYUBVy00RoxJTAjBgkqhkiG9w0BCRUxFgQUBggTTAl4kyDq" +
            "2RNJDTp4A9mhvwwwMTAhMAkGBSsOAwIaBQAEFGhCv6aq9bpEnp8d8d3eyE1O" +
        "A6JFBAjbmojQPVKS/wICCAA="

        return Data(base64Encoded: p12str, options: [])!
    }
}
