import XCTest

class AMQParserTest: XCTestCase {
    
    func testDecodeDataToConnectionStart() {
        let parser   = AMQParser()
        let data     = NSData(contentsOfURL: NSURL(string: "data:application/octet-stream;base64,AAoACgAJAAABvQxjYXBhYmlsaXRpZXNGAAAAtRJwdWJsaXNoZXJfY29uZmlybXN0ARpleGNoYW5nZV9leGNoYW5nZV9iaW5kaW5nc3QBCmJhc2ljLm5hY2t0ARZjb25zdW1lcl9jYW5jZWxfbm90aWZ5dAESY29ubmVjdGlvbi5ibG9ja2VkdAETY29uc3VtZXJfcHJpb3JpdGllc3QBHGF1dGhlbnRpY2F0aW9uX2ZhaWx1cmVfY2xvc2V0ARBwZXJfY29uc3VtZXJfcW9zdAEMY2x1c3Rlcl9uYW1lUwAAACJyYWJiaXRAbXlhcHAuY2ZhcHBzLnBlei5waXZvdGFsLmlvCWNvcHlyaWdodFMAAAAuQ29weXJpZ2h0IChDKSAyMDA3LTIwMTUgUGl2b3RhbCBTb2Z0d2FyZSwgSW5jLgtpbmZvcm1hdGlvblMAAAA1TGljZW5zZWQgdW5kZXIgdGhlIE1QTC4gIFNlZSBodHRwOi8vd3d3LnJhYmJpdG1xLmNvbS8IcGxhdGZvcm1TAAAACkVybGFuZy9PVFAHcHJvZHVjdFMAAAAIUmFiYml0TVEHdmVyc2lvblMAAAAFMy42LjAAAAAOQU1RUExBSU4gUExBSU4AAAAFZW5fVVM=")!)
        let expected = AMQProtocolConnectionStart(
            versionMajor: 0,
            versionMinor: 9,
            serverProperties: [
                "capabilities" : [
                    "authentication_failure_close" : true,
                    "basic.nack" : true,
                    "connection.blocked" : true,
                    "consumer_cancel_notify" : true,
                    "consumer_priorities" : true,
                    "exchange_exchange_bindings" : true,
                    "per_consumer_qos" : true,
                    "publisher_confirms" : true
                ],
                "cluster_name" : "rabbit@myapp.cfapps.pez.pivotal.io",
                "copyright"    : "Copyright (C) 2007-2015 Pivotal Software, Inc.",
                "information"  : "Licensed under the MPL.  See http://www.rabbitmq.com/",
                "platform"     : "Erlang/OTP",
                "product"      : "RabbitMQ",
                "version"      : "3.6.0",
            ]
        )
        let actual : AMQProtocolConnectionStart = parser.parse(data)
        XCTAssertEqual(expected, actual)
    }
    
}
