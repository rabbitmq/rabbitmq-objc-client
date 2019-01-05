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

class MethodFixtures {
    static let rmqTrue = RMQBoolean(true)

    static func basicAck(_ deliveryTag: UInt64, options: RMQBasicAckOptions) -> RMQBasicAck {
        return RMQBasicAck(deliveryTag: RMQLonglong(deliveryTag), options: options)
    }

    static func basicCancel(_ consumerTag: String) -> RMQBasicCancel {
        return RMQBasicCancel(consumerTag: RMQShortstr(consumerTag), options: [])
    }

    static func basicCancelOk(_ consumerTag: String) -> RMQBasicCancelOk {
        return RMQBasicCancelOk(consumerTag: RMQShortstr(consumerTag))
    }

    static func basicConsume(_ queueName: String, consumerTag: String,
                             options: RMQBasicConsumeOptions) -> RMQBasicConsume {
        return RMQBasicConsume(queue: queueName, consumerTag: consumerTag, options: options)
    }

    static func basicConsumeOk(_ consumerTag: String) -> RMQBasicConsumeOk {
        return RMQBasicConsumeOk(consumerTag: RMQShortstr(consumerTag))
    }

    static func basicDeliver(consumerTag: String = "", deliveryTag: UInt64 = 0, routingKey: String = "",
                             exchange: String = "", options: RMQBasicDeliverOptions = []) -> RMQBasicDeliver {
        return RMQBasicDeliver(
            consumerTag: RMQShortstr(consumerTag),
            deliveryTag: RMQLonglong(deliveryTag),
            options: options,
            exchange: RMQShortstr(exchange),
            routingKey: RMQShortstr(routingKey)
        )
    }

    static func basicGet(_ queue: String = "my.queue", options: RMQBasicGetOptions = []) -> RMQBasicGet {
        return RMQBasicGet(reserved1: RMQShort(0), queue: RMQShortstr(queue), options: options)
    }

    static func basicGetOk(routingKey: String, deliveryTag: UInt64 = 0, exchange: String = "",
                           options: RMQBasicGetOkOptions = []) -> RMQBasicGetOk {
        return RMQBasicGetOk(deliveryTag: RMQLonglong(deliveryTag),
                             options: options,
                             exchange: RMQShortstr(exchange),
                             routingKey: RMQShortstr(routingKey),
                             messageCount: RMQLong(0))
    }

    static func basicNack(_ deliveryTag: UInt64, options: RMQBasicNackOptions) -> RMQBasicNack {
        return RMQBasicNack(deliveryTag: RMQLonglong(deliveryTag), options: options)
    }

    static func basicPublish(_ routingKey: String, exchange: String = "",
                             options: RMQBasicPublishOptions = []) -> RMQBasicPublish {
        return RMQBasicPublish(reserved1: RMQShort(0), exchange: RMQShortstr(exchange),
                               routingKey: RMQShortstr(routingKey), options: options)
    }

    static func basicQos(_ prefetchCount: UInt, options: RMQBasicQosOptions) -> RMQBasicQos {
        return RMQBasicQos(prefetchSize: RMQLong(0), prefetchCount: RMQShort(prefetchCount), options: options)
    }

    static func basicQosOk() -> RMQBasicQosOk {
        return RMQBasicQosOk()
    }

    static func basicReject(_ deliveryTag: UInt64, options: RMQBasicRejectOptions) -> RMQBasicReject {
        return RMQBasicReject(deliveryTag: RMQLonglong(deliveryTag), options: options)
    }

    static func channelClose() -> RMQChannelClose {
        return RMQChannelClose()
    }

    static func channelCloseOk() -> RMQChannelCloseOk {
        return RMQChannelCloseOk()
    }

    static func channelOpen() -> RMQChannelOpen {
        return RMQChannelOpen()
    }

    static func channelOpenOk() -> RMQChannelOpenOk {
        return RMQChannelOpenOk(reserved1: RMQLongstr(""))
    }

    static func confirmSelect() -> RMQConfirmSelect {
        return RMQConfirmSelect(options: [])
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
        return RMQConnectionOpen(virtualHost: RMQShortstr("/"), reserved1: RMQShortstr(""),
                                 options: RMQConnectionOpenOptions())
    }

    static func connectionOpenOk() -> RMQConnectionOpenOk {
        return RMQConnectionOpenOk(reserved1: RMQShortstr(""))
    }

    static func connectionStart() -> RMQConnectionStart {
        let dict: [String: RMQBoolean] = [
            "authentication_failure_close": rmqTrue,
            "basic.nack": rmqTrue,
            "connection.blocked": rmqTrue,
            "consumer_cancel_notify": rmqTrue,
            "consumer_priorities": rmqTrue,
            "exchange_exchange_bindings": rmqTrue,
            "per_consumer_qos": rmqTrue,
            "publisher_confirms": rmqTrue
        ]
        let serverPropertiesDict: [String: RMQValue] = [
            "capabilities": RMQTable(dict),
            "cluster_name": RMQLongstr("rabbit@myapp.cfapps.pez.pivotal.io"),
            "copyright": RMQLongstr("Copyright (C) 2007-2019 Pivotal Software, Inc."),
            "information": RMQLongstr("Licensed under the MPL.  See http://www.rabbitmq.com/"),
            "platform": RMQLongstr("Erlang/OTP"),
            "product": RMQLongstr("RabbitMQ"),
            "version": RMQLongstr("3.7.10")
        ]
        return RMQConnectionStart(
            versionMajor: RMQOctet(0),
            versionMinor: RMQOctet(9),
            serverProperties: RMQTable(serverPropertiesDict as! [String : RMQValue & RMQFieldValue]),
            mechanisms: RMQLongstr("AMQPLAIN PLAIN"),
            locales: RMQLongstr("en_US")
        )
    }

    static func connectionStartOk(user: String = "foo",
                                  password: String = "bar",
                                  version: String = "1.1.0") -> RMQConnectionStartOk {
        let capabilitiesDict: [String: RMQBoolean] = [
            "publisher_confirms": rmqTrue,
            "consumer_cancel_notify": rmqTrue,
            "exchange_exchange_bindings": rmqTrue,
            "basic.nack": rmqTrue,
            "connection.blocked": rmqTrue,
            "authentication_failure_close": rmqTrue
        ]
        let clientPropertiesDict: [String: RMQValue] = [
            "capabilities": RMQTable(capabilitiesDict),
            "product": RMQLongstr("RMQClient"),
            "platform": RMQLongstr("iOS"),
            "version": RMQLongstr(version),
            "information": RMQLongstr("https://github.com/rabbitmq/rabbitmq-objc-client")
        ]
        return RMQConnectionStartOk(
            clientProperties: RMQTable(clientPropertiesDict as! [String : RMQValue & RMQFieldValue]),
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

    static func exchangeBind(_ source: String, destination: String, routingKey: String) -> RMQExchangeBind {
        return RMQExchangeBind(destination: destination, source: source, routingKey: routingKey)
    }

    static func exchangeBindOk() -> RMQExchangeBindOk {
        return RMQExchangeBindOk()
    }

    static func exchangeDeclare(_ name: String,
                                type: String,
                                options: RMQExchangeDeclareOptions) -> RMQExchangeDeclare {
        return RMQExchangeDeclare(exchange: name, type: type, options: options)
    }

    static func exchangeDeclareOk() -> RMQExchangeDeclareOk {
        return RMQExchangeDeclareOk()
    }

    static func exchangeDelete(_ name: String, options: RMQExchangeDeleteOptions) -> RMQExchangeDelete {
        return RMQExchangeDelete(reserved1: RMQShort(0), exchange: RMQShortstr(name), options: options)
    }

    static func exchangeDeleteOk() -> RMQExchangeDeleteOk {
        return RMQExchangeDeleteOk()
    }

    static func exchangeUnbind(_ source: String, destination: String, routingKey: String) -> RMQExchangeUnbind {
        return RMQExchangeUnbind(destination: destination, source: source, routingKey: routingKey)
    }

    static func queueBind(_ name: String, exchangeName: String, routingKey: String) -> RMQQueueBind {
        return RMQQueueBind(queue: name, exchange: exchangeName, routingKey: routingKey)
    }

    static func queueBindOk() -> RMQQueueBindOk {
        return RMQQueueBindOk()
    }

    static func queueDeclare(_ name: String,
                             options: RMQQueueDeclareOptions,
                             arguments: [String: RMQValue] = [:]) -> RMQQueueDeclare {
        return RMQQueueDeclare(
            queue: name,
            options: options,
            arguments: RMQTable(arguments as! [String: RMQValue & RMQFieldValue])
        )
    }

    static func queueDeclareOk(_ name: String) -> RMQQueueDeclareOk {
        return RMQQueueDeclareOk(queue: RMQShortstr(name), messageCount: RMQLong(0), consumerCount: RMQLong(0))
    }

    static func queueDelete(_ name: String, options: RMQQueueDeleteOptions) -> RMQQueueDelete {
        return RMQQueueDelete(queue: name, options: options)
    }

    static func queueDeleteOk(_ messageCount: UInt) -> RMQQueueDeleteOk {
        return RMQQueueDeleteOk(messageCount: RMQLong(messageCount))
    }

    static func queueUnbind(_ name: String, exchangeName: String, routingKey: String) -> RMQQueueUnbind {
        return RMQQueueUnbind(queue: name, exchange: exchangeName, routingKey: routingKey)
    }

    static func queueUnbindOk() -> RMQQueueUnbindOk {
        return RMQQueueUnbindOk()
    }
}
