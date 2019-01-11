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

@objc class ChannelSpy: NSObject, RMQChannel {
    var channelNumber: NSNumber

    var lastReceivedBasicConsumeOptions: RMQBasicConsumeOptions = []
    var lastReceivedBasicConsumeBlock: RMQConsumerDeliveryHandler?

    var lastReceivedBasicCancelConsumerTag: String?

    var lastReceivedBasicGetQueue: String?
    var lastReceivedBasicGetOptions: RMQBasicGetOptions?
    var lastReceivedBasicGetCompletionHandler: RMQConsumerDeliveryHandler?

    var lastReceivedBasicPublishMessage: Data?
    var lastReceivedBasicPublishRoutingKey: String?
    var lastReceivedBasicPublishExchange: String?
    var lastReceivedBasicPublishProperties: [RMQValue]?
    var lastReceivedBasicPublishOptions: RMQBasicPublishOptions?

    var lastReceivedQueueBindQueueName: String?
    var lastReceivedQueueBindExchange: String?
    var lastReceivedQueueBindRoutingKey: String?

    var lastReceivedQueueUnbindQueueName: String?
    var lastReceivedQueueUnbindExchange: String?
    var lastReceivedQueueUnbindRoutingKey: String?

    var lastReceivedQueuePurgeQueueName: String?
    var lastReceivedQueuePurgeOptions: RMQQueuePurgeOptions?

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

    var publishReturn = 0
    var queues: [String: RMQQueue] = [:]
    var stubbedMessageCount: RMQLong = RMQLong(0)
    var stubbedConsumerCount: RMQLong = RMQLong(0)
    var lastReceivedQueueDeclareOptions: RMQQueueDeclareOptions = []
    var stubbedBasicConsumeError: String?
    var openCalled = false
    var closeCalled = false
    var currentlyOpen = false
    var blockingCloseCalled = false
    var prepareForRecoveryCalled = false
    var recoverCalled = false
    var blockingWaitOnMethod: AnyClass?
    var delegateSentToActivate: RMQConnectionDelegate?
    var confirmSelectCallback: ((NSNumber, Bool) -> Void)?

    override var description: String {
        return "Channel Spy \(channelNumber)"
    }

    init(channelNumber aChannelNumber: Int) {
        channelNumber = aChannelNumber as NSNumber
    }

    func defaultExchange() -> RMQExchange {
        return RMQExchange(name: "", type: "direct", options: [], channel: self)
    }

    func activate(with delegate: RMQConnectionDelegate?) {
        delegateSentToActivate = delegate
    }

    func open() {
        openCalled = true
        currentlyOpen = true
    }

    func isOpen() -> Bool {
        return currentlyOpen
    }

    func isClosed() -> Bool {
        return !self.isOpen()
    }

    func close() {
        closeCalled = true
        currentlyOpen = false
    }

    func close(_ completionHandler: () -> Void) {
        closeCalled = true
        currentlyOpen = false
    }

    func wasClosedByServer() -> Bool {
        return !isOpen() && !wasClosedExplicitly()
    }

    func wasClosedExplicitly() -> Bool {
        return closeCalled
    }

    func blockingClose() {
        blockingCloseCalled = true
        currentlyOpen = false
    }

    func prepareForRecovery() {
        prepareForRecoveryCalled = true
    }

    func recover() {
        recoverCalled = true
    }

    func blockingWait(on method: AnyClass) {
        blockingWaitOnMethod = method
    }

    func confirmSelect() {
    }

    func afterConfirmed(_ timeout: NSNumber, handler: @escaping (Set<NSNumber>, Set<NSNumber>) -> Swift.Void) {
    }

    func afterConfirmed(_ handler: @escaping (Set<NSNumber>, Set<NSNumber>) -> Void) {
        afterConfirmed(30, handler: handler)
    }

    func sendMethod(_ sendingMethod: RMQMethod,
                    waitOnMethod waitOnMethodClass: AnyClass,
                    completionHandler: (RMQFrameset?, NSError?) -> Void) {
    }

    func queue(_ queueName: String, options: RMQQueueDeclareOptions,
               arguments: [String: RMQValue & RMQFieldValue]) -> RMQQueue {
        if let foundQueue = queues[queueName] {
            return foundQueue
        } else {
            let q = QueueHelper.makeQueue(self, name: queueName, options: options, arguments: arguments)
            queues[queueName] = q
            return q
        }
    }

    func queue(_ queueName: String, options: RMQQueueDeclareOptions) -> RMQQueue {
        return queue(queueName, options: options, arguments: [:])
    }

    func queue(_ queueName: String) -> RMQQueue {
        return queue(queueName, options: [])
    }

    func queueDeclare(_ queueName: String, options: RMQQueueDeclareOptions) -> RMQQueueDeclareOk {
        lastReceivedQueueDeclareOptions = options
        return RMQQueueDeclareOk(
            queue: RMQShortstr(queueName),
            messageCount: stubbedMessageCount,
            consumerCount: stubbedConsumerCount
        )
    }

    func queuePurge(_ queueName: String, options: RMQQueuePurgeOptions = []) {
        lastReceivedQueuePurgeQueueName = queueName
        lastReceivedQueuePurgeOptions = options
    }

    func queueDelete(_ queueName: String, options: RMQQueueDeleteOptions) {
        lastReceivedQueueDeleteQueueName = queueName
        lastReceivedQueueDeleteOptions = options
    }

    func queueBind(_ queueName: String, exchange exchangeName: String, routingKey: String) {
        lastReceivedQueueBindQueueName = queueName
        lastReceivedQueueBindExchange = exchangeName
        lastReceivedQueueBindRoutingKey = routingKey
    }

    func queueUnbind(_ queueName: String, exchange exchangeName: String, routingKey: String) {
        lastReceivedQueueUnbindQueueName = queueName
        lastReceivedQueueUnbindExchange = exchangeName
        lastReceivedQueueUnbindRoutingKey = routingKey
    }

    func basicConsume(_ queueName: String, acknowledgementMode: RMQBasicConsumeAcknowledgementMode,
                      handler: @escaping RMQConsumerDeliveryHandler) -> RMQConsumer {
        let options = RMQBasicConsumeAcknowledgementModeToOptions(acknowledgementMode)
        return basicConsume(queueName, options: options, handler: handler)
    }

    func basicConsume(_ queueName: String, acknowledgementMode: RMQBasicConsumeAcknowledgementMode,
                      arguments: RMQTable, handler: @escaping RMQConsumerDeliveryHandler) -> RMQConsumer {
        let options = RMQBasicConsumeAcknowledgementModeToOptions(acknowledgementMode)
        return basicConsume(queueName, options: options, arguments: arguments, handler: handler)
    }

    func basicConsume(_ queueName: String, options: RMQBasicConsumeOptions,
                      handler: @escaping RMQConsumerDeliveryHandler) -> RMQConsumer {
        lastReceivedBasicConsumeOptions = options
        lastReceivedBasicConsumeBlock = handler
        if let msg = stubbedBasicConsumeError {
            let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            delegateSentToActivate?.channel(self, error: e)
        }
        let consumer = RMQConsumer(channel: self, queueName: queueName, options: options)
        consumer?.onDelivery(handler)
        return consumer!
    }

    func basicConsume(_ queueName: String, options: RMQBasicConsumeOptions = [],
                      arguments: RMQTable, handler: @escaping RMQConsumerDeliveryHandler) -> RMQConsumer {
        lastReceivedBasicConsumeOptions = options
        lastReceivedBasicConsumeBlock = handler
        if let msg = stubbedBasicConsumeError {
            let e = NSError(domain: RMQErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
            delegateSentToActivate?.channel(self, error: e)
        }
        let consumer = RMQConsumer(channel: self, queueName: queueName, options: options, arguments: arguments)
        consumer?.onDelivery(handler)
        return consumer!
    }

    func basicConsume(_ consumer: RMQConsumer) {
    }

    func basicRecover() {
    }

    func generateConsumerTag() -> String {
        return "channel spy consumer tag"
    }

    func basicCancel(_ consumerTag: String) {
        lastReceivedBasicCancelConsumerTag = consumerTag
    }

    func basicPublish(_ body: Data, routingKey: String, exchange: String, properties: [RMQValue],
                      options: RMQBasicPublishOptions) -> NSNumber {
        lastReceivedBasicPublishMessage = body
        lastReceivedBasicPublishRoutingKey = routingKey
        lastReceivedBasicPublishExchange = exchange
        lastReceivedBasicPublishProperties = properties
        lastReceivedBasicPublishOptions = options
        return publishReturn as NSNumber
    }

    func basicGet(_ queue: String, options: RMQBasicGetOptions,
                  completionHandler: @escaping RMQConsumerDeliveryHandler) {
        lastReceivedBasicGetQueue = queue
        lastReceivedBasicGetOptions = options
        lastReceivedBasicGetCompletionHandler = completionHandler
    }

    func ack(_ deliveryTag: NSNumber, options: RMQBasicAckOptions) {
    }

    func ack(_ deliveryTag: NSNumber) {
    }

    func handle(_ frameset: RMQFrameset) {
        lastReceivedFrameset = frameset
    }

    func basicQos(_ count: NSNumber, global isGlobal: Bool) {
    }

    func reject(_ deliveryTag: NSNumber, options: RMQBasicRejectOptions) {
    }

    func reject(_ deliveryTag: NSNumber) {
    }

    func nack(_ deliveryTag: NSNumber, options: RMQBasicNackOptions) {
    }

    func nack(_ deliveryTag: NSNumber) {
    }

    func exchangeDeclare(_ name: String, type: String, options: RMQExchangeDeclareOptions) {
    }

    func exchangeBind(_ sourceName: String, destination destinationName: String, routingKey: String) {
        lastReceivedExchangeBindSourceName = sourceName
        lastReceivedExchangeBindDestinationName = destinationName
        lastReceivedExchangeBindRoutingKey = routingKey
    }

    func exchangeUnbind(_ sourceName: String, destination destinationName: String, routingKey: String) {
        lastReceivedExchangeUnbindSourceName = sourceName
        lastReceivedExchangeUnbindDestinationName = destinationName
        lastReceivedExchangeUnbindRoutingKey = routingKey
    }

    func fanout(_ name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "fanout", options: [], channel: self)
    }

    func fanout(_ name: String) -> RMQExchange {
        return fanout(name, options: [])
    }

    func direct(_ name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "direct", options: [], channel: self)
    }

    func direct(_ name: String) -> RMQExchange {
        return direct(name, options: [])
    }

    func topic(_ name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "topic", options: [], channel: self)
    }

    func topic(_ name: String) -> RMQExchange {
        return topic(name, options: [])
    }

    func headers(_ name: String, options: RMQExchangeDeclareOptions) -> RMQExchange {
        return RMQExchange(name: name, type: "headers", options: [], channel: self)
    }

    func headers(_ name: String) -> RMQExchange {
        return headers(name, options: [])
    }

    func exchangeDelete(_ name: String, options: RMQExchangeDeleteOptions) {
        lastReceivedExchangeDeleteExchangeName = name
        lastReceivedExchangeDeleteOptions = options
    }
}
