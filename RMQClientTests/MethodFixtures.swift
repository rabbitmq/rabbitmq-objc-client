import UIKit

class MethodFixtures {
    static func connectionStart() -> RMQConnectionStart {
        let dict: [String : RMQBoolean] = [
            "authentication_failure_close" : RMQBoolean(true),
            "basic.nack"                   : RMQBoolean(true),
            "connection.blocked"           : RMQBoolean(true),
            "consumer_cancel_notify"       : RMQBoolean(true),
            "consumer_priorities"          : RMQBoolean(true),
            "exchange_exchange_bindings"   : RMQBoolean(true),
            "per_consumer_qos"             : RMQBoolean(true),
            "publisher_confirms"           : RMQBoolean(true)
        ]
        let capabilities = RMQTable(dict)
        return RMQConnectionStart(
            versionMajor: RMQOctet(0),
            versionMinor: RMQOctet(9),
            serverProperties: RMQTable([
                "capabilities" : capabilities,
                "cluster_name" : RMQLongstr("rabbit@myapp.cfapps.pez.pivotal.io"),
                "copyright"    : RMQLongstr("Copyright (C) 2007-2015 Pivotal Software, Inc."),
                "information"  : RMQLongstr("Licensed under the MPL.  See http://www.rabbitmq.com/"),
                "platform"     : RMQLongstr("Erlang/OTP"),
                "product"      : RMQLongstr("RabbitMQ"),
                "version"      : RMQLongstr("3.6.0"),
                ]),
            mechanisms: RMQLongstr("RMQPLAIN PLAIN"),
            locales: RMQLongstr("en_US")
        )
    }

    static func connectionStartOk(user user: String = "foo", password: String = "bar") -> RMQConnectionStartOk {
        let capabilities = RMQTable([
            "publisher_confirms": RMQBoolean(true),
            "consumer_cancel_notify": RMQBoolean(true),
            "exchange_exchange_bindings": RMQBoolean(true),
            "basic.nack": RMQBoolean(true),
            "connection.blocked": RMQBoolean(true),
            "authentication_failure_close": RMQBoolean(true),
            ])
        let clientProperties = RMQTable([
            "capabilities" : capabilities,
            "product"     : RMQLongstr("RMQClient"),
            "platform"    : RMQLongstr("iOS"),
            "version"     : RMQLongstr("0.0.1"),
            "information" : RMQLongstr("https://github.com/camelpunch/RMQClient")
            ])
        return RMQConnectionStartOk(
            clientProperties: clientProperties,
            mechanism: RMQShortstr("PLAIN"),
            response: RMQCredentials(username: user, password: password),
            locale: RMQShortstr("en_GB")
        )
    }

    static func connectionTune() -> RMQConnectionTune {
        return RMQConnectionTune(channelMax: RMQShort(0), frameMax: RMQLong(131072), heartbeat: RMQShort(60))
    }

    static func connectionTuneOk() -> RMQConnectionTuneOk {
        return RMQConnectionTuneOk(channelMax: RMQShort(65535), frameMax: RMQLong(131072), heartbeat: RMQShort(60))
    }

    static func connectionOpen() -> RMQConnectionOpen {
        return RMQConnectionOpen(virtualHost: RMQShortstr("/"), reserved1: RMQShortstr(""), options: RMQConnectionOpenOptions.NoOptions)
    }

    static func connectionOpenOk() -> RMQConnectionOpenOk {
        return RMQConnectionOpenOk(reserved1: RMQShortstr(""))
    }

    static func connectionClose() -> RMQConnectionClose {
        return RMQConnectionClose(
            replyCode: RMQShort(200),
            replyText: RMQShortstr("Goodbye"),
            classId: RMQShort(0),
            methodId: RMQShort(0)
        )
    }

    static func connectionCloseOk() -> RMQConnectionCloseOk {
        return RMQConnectionCloseOk()
    }

    static func channelOpen() -> RMQChannelOpen {
        return RMQChannelOpen(reserved1: RMQShortstr(""))
    }

    static func channelOpenOk() -> RMQChannelOpenOk {
        return RMQChannelOpenOk(reserved1: RMQLongstr(""))
    }

    static func channelClose() -> RMQChannelClose {
        return RMQChannelClose(
            replyCode: RMQShort(200),
            replyText: RMQShortstr("Goodbye"),
            classId: RMQShort(0),
            methodId: RMQShort(0)
        )
    }

    static func channelCloseOk() -> RMQChannelCloseOk {
        return RMQChannelCloseOk()
    }

    static func queueDeclare(name: String, options: RMQQueueDeclareOptions) -> RMQQueueDeclare {
        return RMQQueueDeclare(
            reserved1: RMQShort(0),
            queue: RMQShortstr(name),
            options: options,
            arguments: RMQTable([:])
        )
    }

    static func queueBind(name: String, exchangeName: String, routingKey: String) -> RMQQueueBind {
        return RMQQueueBind(reserved1: RMQShort(0), queue: RMQShortstr(name), exchange: RMQShortstr(exchangeName), routingKey: RMQShortstr(routingKey), options: [], arguments: RMQTable([:]))
    }

    static func queueUnbind(name: String, exchangeName: String, routingKey: String) -> RMQQueueUnbind {
        return RMQQueueUnbind(reserved1: RMQShort(0), queue: RMQShortstr(name), exchange: RMQShortstr(exchangeName), routingKey: RMQShortstr(routingKey), arguments: RMQTable([:]))
    }

    static func basicConsumeOk(consumerTag: String) -> RMQBasicConsumeOk {
        return RMQBasicConsumeOk(consumerTag: RMQShortstr(consumerTag))
    }

    static func basicGet(queue: String = "my.queue", options: RMQBasicGetOptions = []) -> RMQBasicGet {
        return RMQBasicGet(reserved1: RMQShort(0), queue: RMQShortstr(queue), options: options)
    }

    static func basicGetOk(routingKey: String, deliveryTag: UInt64 = 0) -> RMQBasicGetOk {
        return RMQBasicGetOk(deliveryTag: RMQLonglong(deliveryTag), options: RMQBasicGetOkOptions.NoOptions, exchange: RMQShortstr(""), routingKey: RMQShortstr(routingKey), messageCount: RMQLong(0))
    }

    static func basicPublish(message: String, routingKey: String, exchange: String = "", options: RMQBasicPublishOptions = []) -> RMQBasicPublish {
        return RMQBasicPublish(reserved1: RMQShort(0), exchange: RMQShortstr(exchange), routingKey: RMQShortstr(routingKey), options: options)
    }

    static func basicDeliver(consumerTag consumerTag: String = "", deliveryTag: UInt64 = 0) -> RMQBasicDeliver {
        return RMQBasicDeliver(consumerTag: RMQShortstr(consumerTag), deliveryTag: RMQLonglong(deliveryTag), options: RMQBasicDeliverOptions.NoOptions, exchange: RMQShortstr(""), routingKey: RMQShortstr(""))
    }

    static func basicQos(prefetchCount: UInt, options: RMQBasicQosOptions) -> RMQBasicQos {
        return RMQBasicQos(prefetchSize: RMQLong(0), prefetchCount: RMQShort(prefetchCount), options: options)
    }

    static func exchangeDeclare(name: String, type: String, options: RMQExchangeDeclareOptions) -> RMQExchangeDeclare {
        return RMQExchangeDeclare(reserved1: RMQShort(0), exchange: RMQShortstr(name), type: RMQShortstr(type), options: options, arguments: RMQTable([:]))
    }
}