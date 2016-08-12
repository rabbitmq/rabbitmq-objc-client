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

#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQExchange.h"
#import "RMQFrameHandler.h"
#import "RMQQueue.h"

@protocol RMQConnectionDelegate;

/*!
 * @brief Interface to a channel.
 * All operations on channels, except methods with 'blocking' in the name,
 * are asynchronous and execute on a GCD serial queue.
 *
 * @see <a href="http://www.rabbitmq.com/getstarted.html">RabbitMQ tutorials</a>
 */
@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;

/// @brief Closes the channel.
- (void)close;

/// @brief Closes the channel, blocking the calling thread.
- (void)blockingClose;

/*!
 * @brief Turn on publisher confirmations. Sends a confirm.select.
 * @see afterConfirmed
 */
- (void)confirmSelect;

/*!
 * @brief Set a callback that will be called when all prior basic.publishes have been acked or nacked.
 * @discussion Each call to this method delimits a new 'transaction' for a set of basic.publishes.
 * @param handler The callback to be called with a set of acked and a set of nacked delivery IDs.
 */
- (void)afterConfirmed:(void (^ _Nonnull)(NSSet<NSNumber *> * _Nonnull acked, NSSet<NSNumber *> * _Nonnull nacked))handler;
- (void)afterConfirmed:(nonnull NSNumber *)timeout
               handler:(void (^ _Nonnull)(NSSet<NSNumber *> * _Nonnull acked, NSSet<NSNumber *> * _Nonnull nacked))handler;

/// @brief Internal. Starts operations and sends the RMQConnectionDelegate to the channel.
- (void)activateWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Internal. Sends a channel.open.
- (void)open;

/// @brief Internal. Used by automatic connection recovery.
- (void)recover;

/// @brief Internal. Block calling thread until channel receives an incoming AMQP method.
- (void)blockingWaitOn:(nonnull Class)method;

/*!
 * @brief Declare a queue with options and arguments
 * @param queueName The name of the queue to be created. An empty string will cause a name to be generated.
 * @param options   Queue declaration options
 * @param arguments Queue declaration arguments
 * @return A queue instance
 */
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options
                  arguments:(nonnull NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)arguments;

/*!
 * @brief Declare a queue with options
 * @param queueName The name of the queue to be created. An empty string will cause a name to be generated.
 * @param options   Queue declaration options
 * @return A queue instance
 */
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options;

/*!
 * @brief Declare a queue with default options
 * @param queueName The name of the queue to be created. An empty string will cause a name to be generated.
 * @return A queue instance
 */
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

/// @brief Delete a queue
- (void)queueDelete:(nonnull NSString *)queueName
            options:(RMQQueueDeleteOptions)options;

/// @brief Bind a queue to an exchange
- (void)queueBind:(nonnull NSString *)queueName
         exchange:(nonnull NSString *)exchangeName
       routingKey:(nonnull NSString *)routingKey;

/// @brief Unbind a queue from an exchange
- (void)queueUnbind:(nonnull NSString *)queueName
           exchange:(nonnull NSString *)exchangeName
         routingKey:(nonnull NSString *)routingKey;

/*!
 * @brief Consume messages from a queue
 * @see RMQQueue's subscribe method (which has variants with defaults)
 */
- (nonnull RMQConsumer *)basicConsume:(nonnull NSString *)queueName
                              options:(RMQBasicConsumeOptions)options
                              handler:(RMQConsumerDeliveryHandler _Nonnull)handler;
/*!
 * @brief Consume messages from a queue using a pre-built RMQConsumer object
 * @see RMQQueue's subscribe method (which has variants with defaults)
 */
- (void)basicConsume:(nonnull RMQConsumer *)consumer;

/// @brief Internal method used by a consumer object
- (nonnull NSString *)generateConsumerTag;

/// @brief Cancel a consumer
/// @see RMQConsumer's cancel method
- (void)basicCancel:(nonnull NSString *)consumerTag;

/*!
 * @brief  Publish a message.
 *         Publishing to a non-existent exchange will result in a channel-level
 *         protocol exception, which closes the channel.
 *
 * @return A sequence number that correlates to the numbers sent to the afterConfirmation block (when publisher confirmations are enabled).
 */
- (nonnull NSNumber *)basicPublish:(nonnull NSData *)body
                        routingKey:(nonnull NSString *)routingKey
                          exchange:(nonnull NSString *)exchange
                        properties:(nonnull NSArray<RMQValue *> *)properties
                           options:(RMQBasicPublishOptions)options;

/*!
 * @brief Consume messages using basic.get / get-ok
 *        Synchronous: the next message from the server on this channel should be a basic.get-ok
 */
-  (void)basicGet:(nonnull NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumerDeliveryHandler _Nonnull)completionHandler;

/*!
 * @brief Set Quality Of Service options, AKA prefetch.
 *        RabbitMQ has its own interpretation of what these options mean.
 * @see   https://www.rabbitmq.com/consumer-prefetch.html
 */
- (void)basicQos:(nonnull NSNumber *)count
          global:(BOOL)isGlobal;

/*!
 * @brief Acknowledge one or several messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to acknowledge.
 * @param options     When Multiple is set, acknowledges all messages up to and including supplied deliveryTag.
 */
- (void)ack:(nonnull NSNumber *)deliveryTag
    options:(RMQBasicAckOptions)options;

/*!
 * @brief Acknowledge one or several messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to acknowledge.
 */
- (void)ack:(nonnull NSNumber *)deliveryTag;

/*!
 * @brief Reject one or several received messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to reject.
 * @param options     When Requeue is set, requeue rather than discard or dead-letter the message(s).
 * @see   nack:
 */
- (void)reject:(nonnull NSNumber *)deliveryTag
       options:(RMQBasicRejectOptions)options;

/*!
 * @brief Reject one or several received messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to reject.
 * @see   nack:
 */
- (void)reject:(nonnull NSNumber *)deliveryTag;

/*!
 * @brief Reject one or several received messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to reject.
 * @param options     When Multiple is set, rejects all messages up to and including supplied deliveryTag.
 *                    When Requeue is set, requeue rather than discard or dead-letter the message(s).
 * @see   reject:
 */
- (void)nack:(nonnull NSNumber *)deliveryTag
     options:(RMQBasicNackOptions)options;

/*!
 * @brief Reject one or several received messages.
 *        Supply the deliveryTag from the basicGet handler param or basicConsume handler param.
 * @param deliveryTag The tag of the message to reject.
 * @see   reject:
 */
- (void)nack:(nonnull NSNumber *)deliveryTag;

/// @return RMQExchange The default exchange, which allows for convenient ("direct") publishing to queues by name.
- (nonnull RMQExchange *)defaultExchange;

/*!
 * @brief  Create a fanout exchange.
 * @return RMQExchange the new fanout exchange.
 */
- (nonnull RMQExchange *)fanout:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

/*!
 * @brief  Create a fanout exchange.
 * @return RMQExchange the new fanout exchange.
 */
- (nonnull RMQExchange *)fanout:(nonnull NSString *)name;

/*!
 * @brief  Create a direct exchange.
 * @return RMQExchange the new direct exchange.
 */
- (nonnull RMQExchange *)direct:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

/*!
 * @brief  Create a direct exchange.
 * @return RMQExchange the new direct exchange.
 */
- (nonnull RMQExchange *)direct:(nonnull NSString *)name;

/*!
 * @brief  Create a topic exchange.
 * @return RMQExchange the new topic exchange.
 */
- (nonnull RMQExchange *)topic:(nonnull NSString *)name
                       options:(RMQExchangeDeclareOptions)options;

/*!
 * @brief  Create a topic exchange.
 * @return RMQExchange the new topic exchange.
 */
- (nonnull RMQExchange *)topic:(nonnull NSString *)name;

/*!
 * @brief  Create a headers exchange.
 * @return RMQExchange the new headers exchange.
 */
- (nonnull RMQExchange *)headers:(nonnull NSString *)name
                         options:(RMQExchangeDeclareOptions)options;

/*!
 * @brief  Create a headers exchange.
 * @return RMQExchange the new headers exchange.
 */
- (nonnull RMQExchange *)headers:(nonnull NSString *)name;

/*!
 * @brief  Create an exchange of a configurable type.
 * @param  type        The exchange type name.
 * @return RMQExchange The new exchange.
 */
- (void)exchangeDeclare:(nonnull NSString *)name
                   type:(nonnull NSString *)type
                options:(RMQExchangeDeclareOptions)options;

/*!
 * @brief  Bind an exchange to another exchange.
 * @param  sourceName   the name of the exchange from which messages flow across the binding
 * @param  destination: the name of the exchange to which messages flow across the binding
 * @param  routingKey:  the routing key to use for the binding
 */
- (void)exchangeBind:(nonnull NSString *)sourceName
         destination:(nonnull NSString *)destinationName
          routingKey:(nonnull NSString *)routingKey;

/*!
 * @brief  Unbind an exchange from another exchange.
 * @param  sourceName   the name of the exchange from which messages flow across the binding
 * @param  destination: the name of the exchange to which messages flow across the binding
 * @param  routingKey:  the routing key of the binding
 */
- (void)exchangeUnbind:(nonnull NSString *)sourceName
           destination:(nonnull NSString *)destinationName
            routingKey:(nonnull NSString *)routingKey;

/// @brief  Delete an exchange
- (void)exchangeDelete:(nonnull NSString *)name
               options:(RMQExchangeDeleteOptions)options;

@end
