import UIKit

class MethodFixtures {
    static func connectionStart() -> AMQProtocolConnectionStart {
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
        return AMQProtocolConnectionStart(
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
    }

    static func connectionStartOk(user user: String = "foo", password: String = "bar") -> AMQProtocolConnectionStartOk {
        let capabilities = AMQTable([
            "publisher_confirms": AMQBoolean(true),
            "consumer_cancel_notify": AMQBoolean(true),
            "exchange_exchange_bindings": AMQBoolean(true),
            "basic.nack": AMQBoolean(true),
            "connection.blocked": AMQBoolean(true),
            "authentication_failure_close": AMQBoolean(true),
            ])
        let clientProperties = AMQTable([
            "capabilities" : capabilities,
            "product"     : AMQLongstr("RMQClient"),
            "platform"    : AMQLongstr("iOS"),
            "version"     : AMQLongstr("0.0.1"),
            "information" : AMQLongstr("https://github.com/camelpunch/RMQClient")
            ])
        return AMQProtocolConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: AMQShortstr("PLAIN"),
            response: AMQCredentials(username: user, password: password),
            locale: AMQShortstr("en_GB")
        )
    }

    static func connectionTune() -> AMQProtocolConnectionTune {
        return AMQProtocolConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
    }

    static func connectionTuneOk() -> AMQProtocolConnectionTuneOk {
        return AMQProtocolConnectionTuneOk(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
    }

    static func connectionOpen() -> AMQProtocolConnectionOpen {
        return AMQProtocolConnectionOpen(virtualHost: AMQShortstr("/"), reserved1: AMQShortstr(""), reserved2: AMQBit(0))
    }

    static func connectionOpenOk() -> AMQProtocolConnectionOpenOk {
        return AMQProtocolConnectionOpenOk(reserved1: AMQShortstr(""))
    }

    static func connectionClose() -> AMQProtocolConnectionClose {
        return AMQProtocolConnectionClose(
            replyCode: AMQShort(200),
            replyText: AMQShortstr("Goodbye"),
            classId: AMQShort(0),
            methodId: AMQShort(0)
        )
    }

    static func connectionCloseOk() -> AMQProtocolConnectionCloseOk {
        return AMQProtocolConnectionCloseOk()
    }
}

class DataFixtures {
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
        return AMQMethodFrame(channelID: 0, method: start).amqEncoded()
    }

    static func connectionTune() -> NSData {
        return AMQMethodFrame(
            channelID: 0,
            method: AMQProtocolConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
        ).amqEncoded()
    }

    static func connectionOpenOk() -> NSData {
        return AMQMethodFrame(
            channelID: 0,
            method: AMQProtocolConnectionOpenOk(reserved1: AMQShortstr(""))
        ).amqEncoded()
    }

    static func connectionCloseOk() -> NSData {
        return AMQMethodFrame(
            channelID: 0,
            method: AMQProtocolConnectionCloseOk()
        ).amqEncoded()
    }

    static func channelOpenOk() -> NSData {
        return AMQMethodFrame(
            channelID: 0,
            method: AMQProtocolChannelOpenOk(reserved1: AMQLongstr(""))
        ).amqEncoded()
    }

    static func nothing() -> NSData {
        return "".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}