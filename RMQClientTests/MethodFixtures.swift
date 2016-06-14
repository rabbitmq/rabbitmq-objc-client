import UIKit

class MethodFixtures {
    static let rmqTrue = RMQBoolean(true)

    static func basicAck(deliveryTag: UInt64, options: RMQBasicAckOptions) -> RMQBasicAck {
        return RMQBasicAck(deliveryTag: RMQLonglong(deliveryTag), options: options)
    }

    static func basicCancel(consumerTag: String) -> RMQBasicCancel {
        return RMQBasicCancel(consumerTag: RMQShortstr(consumerTag), options: [])
    }

    static func basicCancelOk(consumerTag: String) -> RMQBasicCancelOk {
        return RMQBasicCancelOk(consumerTag: RMQShortstr(consumerTag))
    }

    static func basicConsume(queueName: String, consumerTag: String, options: RMQBasicConsumeOptions) -> RMQBasicConsume {
        return RMQBasicConsume(reserved1: RMQShort(0), queue: RMQShortstr(queueName), consumerTag: RMQShortstr(consumerTag), options: options, arguments: RMQTable([:]))
    }

    static func basicConsumeOk(consumerTag: String) -> RMQBasicConsumeOk {
        return RMQBasicConsumeOk(consumerTag: RMQShortstr(consumerTag))
    }

    static func basicDeliver(consumerTag consumerTag: String = "", deliveryTag: UInt64 = 0, routingKey: String = "", exchange: String = "", options: RMQBasicDeliverOptions = []) -> RMQBasicDeliver {
        return RMQBasicDeliver(
            consumerTag: RMQShortstr(consumerTag),
            deliveryTag: RMQLonglong(deliveryTag),
            options: options,
            exchange: RMQShortstr(exchange),
            routingKey: RMQShortstr(routingKey)
        )
    }

    static func basicGet(queue: String = "my.queue", options: RMQBasicGetOptions = []) -> RMQBasicGet {
        return RMQBasicGet(reserved1: RMQShort(0), queue: RMQShortstr(queue), options: options)
    }

    static func basicGetOk(routingKey routingKey: String, deliveryTag: UInt64 = 0, exchange: String = "", options: RMQBasicGetOkOptions = []) -> RMQBasicGetOk {
        return RMQBasicGetOk(deliveryTag: RMQLonglong(deliveryTag),
                             options: options,
                             exchange: RMQShortstr(exchange),
                             routingKey: RMQShortstr(routingKey),
                             messageCount: RMQLong(0))
    }

    static func basicNack(deliveryTag: UInt64, options: RMQBasicNackOptions) -> RMQBasicNack {
        return RMQBasicNack(deliveryTag: RMQLonglong(deliveryTag), options: options)
    }

    static func basicPublish(routingKey: String, exchange: String = "", options: RMQBasicPublishOptions = []) -> RMQBasicPublish {
        return RMQBasicPublish(reserved1: RMQShort(0), exchange: RMQShortstr(exchange), routingKey: RMQShortstr(routingKey), options: options)
    }

    static func basicQos(prefetchCount: UInt, options: RMQBasicQosOptions) -> RMQBasicQos {
        return RMQBasicQos(prefetchSize: RMQLong(0), prefetchCount: RMQShort(prefetchCount), options: options)
    }

    static func basicQosOk() -> RMQBasicQosOk {
        return RMQBasicQosOk()
    }

    static func basicReject(deliveryTag: UInt64, options: RMQBasicRejectOptions) -> RMQBasicReject {
        return RMQBasicReject(deliveryTag: RMQLonglong(deliveryTag), options: options)
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

    static func channelOpen() -> RMQChannelOpen {
        return RMQChannelOpen(reserved1: RMQShortstr(""))
    }

    static func channelOpenOk() -> RMQChannelOpenOk {
        return RMQChannelOpenOk(reserved1: RMQLongstr(""))
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

    static func connectionOpen() -> RMQConnectionOpen {
        return RMQConnectionOpen(virtualHost: RMQShortstr("/"), reserved1: RMQShortstr(""), options: RMQConnectionOpenOptions.NoOptions)
    }

    static func connectionOpenOk() -> RMQConnectionOpenOk {
        return RMQConnectionOpenOk(reserved1: RMQShortstr(""))
    }

    static func connectionStart() -> RMQConnectionStart {
        let dict: [String: RMQBoolean] = [
            "authentication_failure_close" : rmqTrue,
            "basic.nack"                   : rmqTrue,
            "connection.blocked"           : rmqTrue,
            "consumer_cancel_notify"       : rmqTrue,
            "consumer_priorities"          : rmqTrue,
            "exchange_exchange_bindings"   : rmqTrue,
            "per_consumer_qos"             : rmqTrue,
            "publisher_confirms"           : rmqTrue
        ]
        let serverPropertiesDict: [String: RMQValue] = [
            "capabilities" : RMQTable(dict),
            "cluster_name" : RMQLongstr("rabbit@myapp.cfapps.pez.pivotal.io"),
            "copyright"    : RMQLongstr("Copyright (C) 2007-2015 Pivotal Software, Inc."),
            "information"  : RMQLongstr("Licensed under the MPL.  See http://www.rabbitmq.com/"),
            "platform"     : RMQLongstr("Erlang/OTP"),
            "product"      : RMQLongstr("RabbitMQ"),
            "version"      : RMQLongstr("3.6.0")
        ]
        return RMQConnectionStart(
            versionMajor: RMQOctet(0),
            versionMinor: RMQOctet(9),
            serverProperties: RMQTable(serverPropertiesDict),
            mechanisms: RMQLongstr("AMQPLAIN PLAIN"),
            locales: RMQLongstr("en_US")
        )
    }

    static func connectionStartOk(user user: String = "foo", password: String = "bar", version: String = "0.0.1") -> RMQConnectionStartOk {
        let capabilitiesDict: [String: RMQBoolean] = [
            "publisher_confirms"           : rmqTrue,
            "consumer_cancel_notify"       : rmqTrue,
            "exchange_exchange_bindings"   : rmqTrue,
            "basic.nack"                   : rmqTrue,
            "connection.blocked"           : rmqTrue,
            "authentication_failure_close" : rmqTrue
        ]
        let clientPropertiesDict: [String: RMQValue] = [
            "capabilities" : RMQTable(capabilitiesDict),
            "product"      : RMQLongstr("RMQClient"),
            "platform"     : RMQLongstr("iOS"),
            "version"      : RMQLongstr(version),
            "information"  : RMQLongstr("https://github.com/rabbitmq/rabbitmq-objc-client")
        ]
        return RMQConnectionStartOk(
            clientProperties: RMQTable(clientPropertiesDict),
            mechanism: RMQShortstr("PLAIN"),
            response: RMQCredentials(username: user, password: password),
            locale: RMQShortstr("en_GB")
        )
    }

    static func connectionTune() -> RMQConnectionTune {
        return RMQConnectionTune(channelMax: RMQShort(0), frameMax: RMQLong(RMQFrameMax), heartbeat: RMQShort(60))
    }

    static func connectionTuneOk() -> RMQConnectionTuneOk {
        return RMQConnectionTuneOk(channelMax: RMQShort(65535), frameMax: RMQLong(RMQFrameMax), heartbeat: RMQShort(60))
    }

    static func exchangeBind(source: String, destination: String, routingKey: String) -> RMQExchangeBind {
        return RMQExchangeBind(reserved1: RMQShort(0), destination: RMQShortstr(destination), source: RMQShortstr(source), routingKey: RMQShortstr(routingKey), options: [], arguments: RMQTable([:]))
    }

    static func exchangeBindOk() -> RMQExchangeBindOk {
        return RMQExchangeBindOk()
    }

    static func exchangeDeclare(name: String, type: String, options: RMQExchangeDeclareOptions) -> RMQExchangeDeclare {
        return RMQExchangeDeclare(reserved1: RMQShort(0), exchange: RMQShortstr(name), type: RMQShortstr(type), options: options, arguments: RMQTable([:]))
    }

    static func exchangeDeclareOk() -> RMQExchangeDeclareOk {
        return RMQExchangeDeclareOk()
    }

    static func exchangeDelete(name: String, options: RMQExchangeDeleteOptions) -> RMQExchangeDelete {
        return RMQExchangeDelete(reserved1: RMQShort(0), exchange: RMQShortstr(name), options: options)
    }

    static func exchangeDeleteOk() -> RMQExchangeDeleteOk {
        return RMQExchangeDeleteOk()
    }

    static func exchangeUnbind(source: String, destination: String, routingKey: String) -> RMQExchangeUnbind {
        return RMQExchangeUnbind(reserved1: RMQShort(0), destination: RMQShortstr(destination), source: RMQShortstr(source), routingKey: RMQShortstr(routingKey), options: [], arguments: RMQTable([:]))
    }

    static func queueBind(name: String, exchangeName: String, routingKey: String) -> RMQQueueBind {
        return RMQQueueBind(reserved1: RMQShort(0), queue: RMQShortstr(name), exchange: RMQShortstr(exchangeName), routingKey: RMQShortstr(routingKey), options: [], arguments: RMQTable([:]))
    }

    static func queueBindOk() -> RMQQueueBindOk {
        return RMQQueueBindOk()
    }

    static func queueDeclare(name: String, options: RMQQueueDeclareOptions) -> RMQQueueDeclare {
        return RMQQueueDeclare(
            reserved1: RMQShort(0),
            queue: RMQShortstr(name),
            options: options,
            arguments: RMQTable([:])
        )
    }

    static func queueDeclareOk(name: String) -> RMQQueueDeclareOk {
        return RMQQueueDeclareOk(queue: RMQShortstr(name), messageCount: RMQLong(0), consumerCount: RMQLong(0))
    }

    static func queueDelete(name: String, options: RMQQueueDeleteOptions) -> RMQQueueDelete {
        return RMQQueueDelete(reserved1: RMQShort(0), queue: RMQShortstr(name), options: options)
    }

    static func queueDeleteOk(messageCount: UInt) -> RMQQueueDeleteOk {
        return RMQQueueDeleteOk(messageCount: RMQLong(messageCount))
    }

    static func queueUnbind(name: String, exchangeName: String, routingKey: String) -> RMQQueueUnbind {
        return RMQQueueUnbind(reserved1: RMQShort(0), queue: RMQShortstr(name), exchange: RMQShortstr(exchangeName), routingKey: RMQShortstr(routingKey), arguments: RMQTable([:]))
    }

    static func queueUnbindOk() -> RMQQueueUnbindOk {
        return RMQQueueUnbindOk()
    }
}