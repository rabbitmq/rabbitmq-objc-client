import UIKit

class Fixtures {
    static func connectionStart() -> NSData {
        let capabilities = AMQTable([
            "authentication_failure_close" : AMQBoolean(true),
            "basic.nack"                   : AMQBoolean(true),
            "connection.blocked"           : AMQBoolean(true),
            "consumer_cancel_notify"       : AMQBoolean(true),
            "consumer_priorities"          : AMQBoolean(true),
            "exchange_exchange_bindings"   : AMQBoolean(true),
            "per_consumer_qos"             : AMQBoolean(true),
            "publisher_confirms"           : AMQBoolean(true)
            ])
        let start = AMQProtocolConnectionStart(
            versionMajor: AMQOctet(0),
            versionMinor: AMQOctet(9),
            serverProperties: AMQTable([
                "capabilities" : capabilities,
                "cluster_name" : AMQLongstr("rabbit@myapp.cfapps.pez.pivotal.io"),
                "copyright"    : AMQLongstr("Copyright (C) 2007-2015 Pivotal Software, Inc."),
                "information"  : AMQLongstr("Licensed under the MPL.  See http://www.rabbitmq.com/"),
                "platform"     : AMQLongstr("Erlang/OTP"),
                "product"      : AMQLongstr("RabbitMQ"),
                "version"      : AMQLongstr("3.6.0"),
            ]),
            mechanisms: AMQLongstr("AMQPLAIN PLAIN"),
            locales: AMQLongstr("en_US")
        )
        return AMQEncoder().encodeMethod(start, channelID: 0)
    }

    static func connectionTune() -> NSData {
        return AMQEncoder().encodeMethod(
            AMQProtocolConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60)),
            channelID: 0
        )
    }

    static func connectionOpenOk() -> NSData {
        return AMQEncoder().encodeMethod(AMQProtocolConnectionOpenOk(reserved1: AMQShortstr("")), channelID: 0)
    }

    static func connectionCloseOk() -> NSData {
        return AMQEncoder().encodeMethod(AMQProtocolConnectionCloseOk(), channelID: 0)
    }

    static func channelOpenOk() -> NSData {
        return AMQEncoder().encodeMethod(AMQProtocolChannelOpenOk(reserved1: AMQLongstr("")), channelID: 1)
    }

    static func nothing() -> NSData {
        return "".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}