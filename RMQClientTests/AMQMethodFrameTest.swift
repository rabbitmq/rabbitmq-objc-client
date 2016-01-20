import XCTest

class AMQMethodFrameTest: XCTestCase {
    
    func testParseConnectionStart() {
        let expected = AMQProtocolConnectionStart(
            versionMajor: 0,
            versionMinor: 9,
            serverProperties: [
                "capabilities" : [
                    "authentication_failure_close" : true,
                    "basic.nack"                   : true,
                    "connection.blocked"           : true,
                    "consumer_cancel_notify"       : true,
                    "consumer_priorities"          : true,
                    "exchange_exchange_bindings"   : true,
                    "per_consumer_qos"             : true,
                    "publisher_confirms"           : true
                ],
                "cluster_name" : "rabbit@myapp.cfapps.pez.pivotal.io",
                "copyright"    : "Copyright (C) 2007-2015 Pivotal Software, Inc.",
                "information"  : "Licensed under the MPL.  See http://www.rabbitmq.com/",
                "platform"     : "Erlang/OTP",
                "product"      : "RabbitMQ",
                "version"      : "3.6.0",
            ],
            mechanisms: "AMQPLAIN PLAIN",
            locales: "en_US"
        )
        let actual = AMQMethodFrame().parse(Fixtures().connectionStart()) as! AMQProtocolConnectionStart
        XCTAssertEqual(expected, actual)
    }
    
}
