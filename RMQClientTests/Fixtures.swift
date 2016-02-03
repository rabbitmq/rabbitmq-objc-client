import UIKit

class Fixtures {
    static func protocolHeader() -> NSData {
        let data = "AMQP".dataUsingEncoding(NSASCIIStringEncoding) as! NSMutableData
        let a = [0x00, 0x00, 0x09, 0x01]
        for var b in a {
            data.appendBytes(&b, length: 1)
        }
        return data
    }

    static func connectionStart() -> NSData {
        return NSData(contentsOfURL: NSURL(string: "data:application/octet-stream;base64,AAoACgAJAAABvQxjYXBhYmlsaXRpZXNGAAAAtRJwdWJsaXNoZXJfY29uZmlybXN0ARpleGNoYW5nZV9leGNoYW5nZV9iaW5kaW5nc3QBCmJhc2ljLm5hY2t0ARZjb25zdW1lcl9jYW5jZWxfbm90aWZ5dAESY29ubmVjdGlvbi5ibG9ja2VkdAETY29uc3VtZXJfcHJpb3JpdGllc3QBHGF1dGhlbnRpY2F0aW9uX2ZhaWx1cmVfY2xvc2V0ARBwZXJfY29uc3VtZXJfcW9zdAEMY2x1c3Rlcl9uYW1lUwAAACJyYWJiaXRAbXlhcHAuY2ZhcHBzLnBlei5waXZvdGFsLmlvCWNvcHlyaWdodFMAAAAuQ29weXJpZ2h0IChDKSAyMDA3LTIwMTUgUGl2b3RhbCBTb2Z0d2FyZSwgSW5jLgtpbmZvcm1hdGlvblMAAAA1TGljZW5zZWQgdW5kZXIgdGhlIE1QTC4gIFNlZSBodHRwOi8vd3d3LnJhYmJpdG1xLmNvbS8IcGxhdGZvcm1TAAAACkVybGFuZy9PVFAHcHJvZHVjdFMAAAAIUmFiYml0TVEHdmVyc2lvblMAAAAFMy42LjAAAAAOQU1RUExBSU4gUExBSU4AAAAFZW5fVVM=")!)!
    }
    
    static func nothing() -> NSData {
        return "".dataUsingEncoding(NSASCIIStringEncoding)!
    }
}