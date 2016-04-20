import UIKit

class MethodFixtures {
    static func connectionStart() -> AMQConnectionStart {
        let dict: [String : AMQBoolean] = [
            "authentication_failure_close" : AMQBoolean(true),
            "basic.nack"                   : AMQBoolean(true),
            "connection.blocked"           : AMQBoolean(true),
            "consumer_cancel_notify"       : AMQBoolean(true),
            "consumer_priorities"          : AMQBoolean(true),
            "exchange_exchange_bindings"   : AMQBoolean(true),
            "per_consumer_qos"             : AMQBoolean(true),
            "publisher_confirms"           : AMQBoolean(true)
        ]
        let capabilities = AMQTable(dict)
        return AMQConnectionStart(
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

    static func connectionStartOk(user user: String = "foo", password: String = "bar") -> AMQConnectionStartOk {
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
        return AMQConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: AMQShortstr("PLAIN"),
            response: AMQCredentials(username: user, password: password),
            locale: AMQShortstr("en_GB")
        )
    }

    static func connectionTune() -> AMQConnectionTune {
        return AMQConnectionTune(channelMax: AMQShort(0), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
    }

    static func connectionTuneOk() -> AMQConnectionTuneOk {
        return AMQConnectionTuneOk(channelMax: AMQShort(65535), frameMax: AMQLong(131072), heartbeat: AMQShort(60))
    }

    static func connectionOpen() -> AMQConnectionOpen {
        return AMQConnectionOpen(virtualHost: AMQShortstr("/"), reserved1: AMQShortstr(""), options: AMQConnectionOpenOptions.NoOptions)
    }

    static func connectionOpenOk() -> AMQConnectionOpenOk {
        return AMQConnectionOpenOk(reserved1: AMQShortstr(""))
    }

    static func connectionClose() -> AMQConnectionClose {
        return AMQConnectionClose(
            replyCode: AMQShort(200),
            replyText: AMQShortstr("Goodbye"),
            classId: AMQShort(0),
            methodId: AMQShort(0)
        )
    }

    static func connectionCloseOk() -> AMQConnectionCloseOk {
        return AMQConnectionCloseOk()
    }

    static func channelOpen() -> AMQChannelOpen {
        return AMQChannelOpen(reserved1: AMQShortstr(""))
    }

    static func channelOpenOk() -> AMQChannelOpenOk {
        return AMQChannelOpenOk(reserved1: AMQLongstr(""))
    }

    static func channelClose() -> AMQChannelClose {
        return AMQChannelClose(
            replyCode: AMQShort(200),
            replyText: AMQShortstr("Goodbye"),
            classId: AMQShort(0),
            methodId: AMQShort(0)
        )
    }

    static func channelCloseOk() -> AMQChannelCloseOk {
        return AMQChannelCloseOk()
    }

    static func queueDeclare(name: String) -> AMQQueueDeclare {
        return AMQQueueDeclare(
            reserved1: AMQShort(0),
            queue: AMQShortstr(name),
            options: AMQQueueDeclareOptions.Durable,
            arguments: AMQTable([:])
        )
    }

    static func basicConsumeOk(consumerTag: String) -> AMQBasicConsumeOk {
        return AMQBasicConsumeOk(consumerTag: AMQShortstr(consumerTag))
    }

    static func basicGet(queue: String = "my.queue", options: AMQBasicGetOptions = []) -> AMQBasicGet {
        return AMQBasicGet(reserved1: AMQShort(0), queue: AMQShortstr(queue), options: options)
    }

    static func basicGetOk(routingKey: String, deliveryTag: UInt64 = 0) -> AMQBasicGetOk {
        return AMQBasicGetOk(deliveryTag: AMQLonglong(deliveryTag), options: AMQBasicGetOkOptions.NoOptions, exchange: AMQShortstr(""), routingKey: AMQShortstr(routingKey), messageCount: AMQLong(0))
    }

    static func basicPublish(message: String, routingKey: String, exchange: String = "", options: AMQBasicPublishOptions = []) -> AMQBasicPublish {
        return AMQBasicPublish(reserved1: AMQShort(0), exchange: AMQShortstr(exchange), routingKey: AMQShortstr(routingKey), options: options)
    }

    static func basicDeliver(consumerTag consumerTag: String = "", deliveryTag: UInt64 = 0) -> AMQBasicDeliver {
        return AMQBasicDeliver(consumerTag: AMQShortstr(consumerTag), deliveryTag: AMQLonglong(deliveryTag), options: AMQBasicDeliverOptions.NoOptions, exchange: AMQShortstr(""), routingKey: AMQShortstr(""))
    }

    static func basicQos(prefetchCount: UInt, options: AMQBasicQosOptions) -> AMQBasicQos {
        return AMQBasicQos(prefetchSize: AMQLong(0), prefetchCount: AMQShort(prefetchCount), options: options)
    }
}