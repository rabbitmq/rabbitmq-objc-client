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

@objc class ChannelSpy : NSObject, RMQChannel {
    var channelNumber: NSNumber

    var lastReceivedBasicConsumeOptions: RMQBasicConsumeOptions = []
    var lastReceivedBasicConsumeBlock: RMQConsumerDeliveryHandler?

    var lastReceivedBasicCancelConsumerTag: String?

    var lastReceivedBasicGetQueue: String?
    var lastReceivedBasicGetOptions: RMQBasicGetOptions?
    var lastReceivedBasicGetCompletionHandler: RMQConsumerDeliveryHandler?

    var lastReceivedBasicPublishMessage: NSData?
    var lastReceivedBasicPublishRoutingKey: String?
    var lastReceivedBasicPublishExchange: String?
    var lastReceivedBasicPublishProperties: Array<RMQValue>?
    var lastReceivedBasicPublishOptions: RMQBasicPublishOptions?

    var lastReceivedQueueBindQueueName: String?
    var lastReceivedQueueBindExchange: String?
    var lastReceivedQueueBindRoutingKey: String?

    var lastReceivedQueueUnbindQueueName: String?
    var lastReceivedQueueUnbindExchange: String?
    var lastReceivedQueueUnbindRoutingKey: String?

    var lastReceivedQueueDeleteQueueName: String?
    var lastReceivedQueueDeleteOptions: RMQQueueDeleteOptions?

    var lastReceivedExchangeBindDestinationName: String?
    var lastReceivedExchangeBindSourceName: String?
    var lastReceivedExchangeBindRoutingKey: String?

    var lastReceivedExchangeUnbindDestinationName: String?
    var lastReceivedExchangeUnbindSourceName: String?
    var lastReceivedExchangeUnbindRoutingKey: String?

    var lastReceivedExchangeDeleteExchangeName: String?
    var lastReceivedExchangeDeleteOptions: RMQExchangeDeleteOptions?

    var lastReceivedFrameset: RMQFrameset?
    var queues: [String: RMQQueue] = [:]
    var stubbedMessageCount: RMQLong = RMQLong(0)
    var stubbedConsumerCount: RMQLong = RMQLong(0)
    var lastReceivedQueueDeclareOptions: RMQQueueDeclareOptions = []
    var stubbedBasicConsumeError: String?
    var openCalled = false
    var closeCalled = false
    var blockingCloseCalled = false
    var prepareForRecoveryCalled = false
    var recoverCalled = false
    var blockingWaitOnMethod: AnyClass?
    var delegateSentToActivate: RMQConnectionDelegate?
    var confirmSelectCallback: ((NSNumber, Bool) -> Void)?

    override var description: String {
        return "Channel Spy \(channelNumber)"
    }

    init(_ aChannelNumber: Int) {
        channelNumber = aChannelNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange(name: "", type: "direct", options: [], channel: self)
    }

    func activateWithDelegate(delegate: RMQConnectionDelegate?) {
        delegateSentToActivate = delegate
    }

    func open() {
        openCalled = true
    }

    func close() {
        closeCalled = true
    }

    func blockingClose() {
        blockingCloseCalled = true
    }

    func prepareForRecovery() {
        prepareForRecoveryCalled = true
    }

    func recover() {
        recoverCalled = true
    }

    func blockingWaitOn(method: AnyClass) {
        blockingWaitOnMethod = method
    }

    func confirmSelect() {
    }

    func afterConfirmed(handler: (Set<NSNumber>, Set<NSNumber>) -> Void) {
    }

    func sendMethod(sendingMethod: RMQMethod,
                    waitOnMethod waitOnMethodClass: AnyClass,
                    completionHandler: (RMQFrameset?, NSError?) -> Void) {
    }

    func queue(queueName: String, options: RMQQueueDeclareOptions, arguments: [String : RMQValue]) -> RMQQueue {
        if let foundQueue = queues[queueName] {
            return foundQueue;
        } else {
            let q = QueueHelper.makeQueue(self, name: queueName, options: options, arguments: arguments)
            queues[queueName] = q
            return q
        }
    }

    func queue(queueName: String, options: RMQQueueDeclareOptions) -> RMQQueue {
        return queue(queueName, options: options, arguments: [:])
    }

    func queue(queueName: String) -> RMQQueue {
        return queue(queueName, options: [])
    }

    func queueDeclare(queueName: String, options: RMQQueueDeclareOptions) -> RMQQueueDeclareOk {
        lastReceivedQueueDeclareOptions = options
        return RMQQueueDeclareOk(
            queue: RMQShortstr(queueName),
            messageCount: stubbedMessageCount,
            consumerCount: stubbedConsumerCount
        )
    }

    func queueDelete(queueName: String, options: RMQQueueDeleteOptions) {
        lastReceivedQueueDeleteQueueName = queueName
        lastReceivedQueueDeleteOptions = options
    }

    func queueBind(queueName: String, exchange exchangeName: String, routingKey: String) {
        lastReceivedQueueBindQueueName = queueName
        lastReceivedQueueBindExchange = exchangeName
        lastReceivedQueueBindRoutingKey = routingKey
    }

    func queueUnbind(queueName: String, exchange exchangeName: String, routingKey: String) {
        lastReceivedQueueUnbindQueueName = queueName
        lastReceivedQueueUnbindExchange = exchangeName
        lastReceivedQueueUnbindRoutingKey = routingKey
    }

    func basicConsume(queueName: String, options: RMQBasicConsumeOptions, handler: RMQConsumerDeliveryHandler) -> RMQConsumer {
        lastReceivedBasicConsumeOptions = options
        lastReceivedBasicConsumeBlock = handler
        if let msg = stubbedBasicConsumeError {
            let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            delegateSentToActivate?.channel(self, error: e)
        }
        return RMQConsumer(queueName: queueName,
                           options: options,
                           consumerTag: "channel spy consumer tag",
                           handler: handler,
                           channel: self)
    }

    func basicCancel(consumerTag: String) {
        lastReceivedBasicCancelConsumerTag = consumerTag
    }

    func basicPublish(body: NSData, routingKey: String, exchange: String, properties: [RMQValue], options: RMQBasicPublishOptions) {
        lastReceivedBasicPublishMessage = body
        lastReceivedBasicPublishRoutingKey = routingKey
        lastReceivedBasicPublishExchange = exchange
        lastReceivedBasicPublishProperties = properties
        lastReceivedBasicPublishOptions = options
    }

    func basicGet(queue: String, options: RMQBasicGetOptions, completionHandler: RMQConsumerDeliveryHandler) {
        lastReceivedBasicGetQueue = queue
        lastReceivedBasicGetOptions = options
        lastReceivedBasicGetCompletionHandler = completionHandler
    }

    func ack(deliveryTag: NSNumber, options: RMQBasicAckOptions) {
    }

    func ack(deliveryTag: NSNumber) {
    }

    func handleFrameset(frameset: RMQFrameset) {
        lastReceivedFrameset = frameset
    }

    func basicQos(count: NSNumber, global isGlobal: Bool) {
    }

    func reject(deliveryTag: NSNumber, options: RMQBasicRejectOptions) {
    }

    func reject(deliveryTag: NSNumber) {
    }

    func nack(deliveryTag: NSNumber, options: RMQBasicNackOptions) {
    }

    func nack(deliveryTag: NSNumber) {
    }

    func exchangeDeclare(name: String, type: String, options: RMQExchangeDeclareOptions) {
    }

    func exchangeBind(sourceName: String, destination destinationName: String, routingKey: String) {
        lastReceivedExchangeBindSourceName = sourceName
        lastReceivedExchangeBindDestinationName = destinationName
        lastReceivedExchangeBindRoutingKey = routingKey
    }

    func exchangeUnbind(sourceName: String, destination destinationName: String, routingKey: String) {
        lastReceivedExchangeUnbindSourceName = sourceName
        lastReceivedExchangeUnbindDestinationName = destinationName
        lastReceivedExchangeUnbindRoutingKey = routingKey
    }

    func fanout(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "fanout", options: [], channel: self)
    }

    func fanout(name: String) -> RMQExchange {
        return fanout(name, options: [])
    }

    func direct(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "direct", options: [], channel: self)
    }

    func direct(name: String) -> RMQExchange {
        return direct(name, options: [])
    }

    func topic(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "topic", options: [], channel: self)
    }

    func topic(name: String) -> RMQExchange {
        return topic(name, options: [])
    }

    func headers(name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "headers", options: [], channel: self)
    }

    func headers(name: String) -> RMQExchange {
        return headers(name, options: [])
    }

    func exchangeDelete(name: String, options: RMQExchangeDeleteOptions) {
        lastReceivedExchangeDeleteExchangeName = name
        lastReceivedExchangeDeleteOptions = options
    }
}
