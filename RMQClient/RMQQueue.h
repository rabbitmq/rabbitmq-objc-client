// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 2.0 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2022 VMware, Inc. or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v2.0:
//
// ---------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2007-2022 VMware, Inc. or its affiliates.  All rights reserved.
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
#import "RMQMethods+Convenience.h"
#import "RMQMessage.h"
#import "RMQExchange.h"
#import "RMQConsumer.h"
#import "RMQConsumerHandlers.h"
#import "RMQBasicProperties.h"

@protocol RMQChannel;

/*!
 * @brief Interface to a queue.
 * All operations delegate to the associated RMQChannel.
 */
@interface RMQQueue : NSObject
@property (copy, nonnull, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) RMQQueueDeclareOptions options;
@property (nonatomic, nullable, readonly) RMQTable *arguments;

/// @brief Internal constructor used by RMQChannel
- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             options:(RMQQueueDeclareOptions)options
                            arguments:(nullable RMQTable *)arguments
                              channel:(nonnull id <RMQChannel>)channel;

/// @brief Bind this queue to an exchange
- (nonnull instancetype)bind:(nonnull RMQExchange *)exchange
                  routingKey:(nonnull NSString *)routingKey;
/// @brief Bind this queue to an exchange
- (nonnull instancetype)bind:(nonnull RMQExchange *)exchange;
/// @brief Unbind this queue from an exchange
- (nonnull instancetype)unbind:(nonnull RMQExchange *)exchange
                    routingKey:(nonnull NSString *)routingKey;
/// @brief Unbind this queue from an exchange
- (nonnull instancetype)unbind:(nonnull RMQExchange *)exchange;

/// @brief Purges this queue
- (void)purge:(RMQQueuePurgeOptions)options;
/// @brief Purges this queue
- (void)purge;

/// @brief Delete this queue
- (void)delete:(RMQQueueDeleteOptions)options;
/// @brief Delete this queue
- (void)delete;

/*!
 * @brief  Publish a message to this queue using the default exchange
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   properties:(nullable NSArray <RMQValue<RMQBasicValue> *> *)properties
                      options:(RMQBasicPublishOptions)options;

/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for setting persistent property and no other properties.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
           persistent:(BOOL)isPersistent
              options:(RMQBasicPublishOptions)options;

/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for setting persistent property and no other properties or options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   persistent:(BOOL)isPersistent;

/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for publishing without persistence or any other properties / options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body;

/// @brief  Perform an RMQChannel#basicGet with the current queue's name.
- (void)pop:(nullable RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Registers a consumer on this queue using the manual acknowledgement mode.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribe:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Register a consumer on this queue using the provided options
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                           handler:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name, options and arguments.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                         arguments:(nullable RMQTable *)arguments
                           handler:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name
 *        and using the automatic acknowledgement mode.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribeAutoAcks:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name
 *        and using the manual acknowledgement mode.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribeManualAcks:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribeWithAckMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                                      handler:(nonnull RMQConsumerDeliveryHandler)handler;

/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name, options and arguments.
 *        Returns an RMQConsumer instance that can be used to cancel the consumer.
 */
- (nonnull RMQConsumer *)subscribeWithAckMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                                    arguments:(nonnull RMQTable *)arguments
                                      handler:(nonnull RMQConsumerDeliveryHandler)handler;
@end
