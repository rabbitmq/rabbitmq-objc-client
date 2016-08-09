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
@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) RMQQueueDeclareOptions options;
@property (nonatomic, readonly) RMQTable *arguments;

/// @brief Internal constructor used by RMQChannel
- (instancetype)initWithName:(NSString *)name
                     options:(RMQQueueDeclareOptions)options
                   arguments:(RMQTable *)arguments
                     channel:(id <RMQChannel>)channel;

/// @brief Bind this queue to an exchange
- (void)bind:(RMQExchange *)exchange routingKey:(NSString *)routingKey;
/// @brief Bind this queue to an exchange
- (void)bind:(RMQExchange *)exchange;
/// @brief Unbind this queue from an exchange
- (void)unbind:(RMQExchange *)exchange routingKey:(NSString *)routingKey;
/// @brief Unbind this queue from an exchange
- (void)unbind:(RMQExchange *)exchange;
/// @brief Delete this queue
- (void)delete:(RMQQueueDeleteOptions)options;
/// @brief Delete this queue
- (void)delete;
/*!
 * @brief  Publish a message to this queue using the default exchange
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (NSNumber *)publish:(NSData *)body
           properties:(NSArray <RMQValue<RMQBasicValue> *> *)properties
              options:(RMQBasicPublishOptions)options;
/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for setting persistent property and no other properties.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (NSNumber *)publish:(NSData *)body
           persistent:(BOOL)isPersistent
              options:(RMQBasicPublishOptions)options;
/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for setting persistent property and no other properties or options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (NSNumber *)publish:(NSData *)body
           persistent:(BOOL)isPersistent;
/*!
 * @brief  Publish a message to this queue using the default exchange
 *         Convenience method for publishing without persistence or any other properties / options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (NSNumber *)publish:(NSData *)body;
/// @brief  Perform an RMQChannel#basicGet with the current queue's name.
- (void)pop:(RMQConsumerDeliveryHandler)handler;
/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name.
 *        Pass an RMQConsumer instance to that method to customise cancellation behaviour.
 */
- (RMQConsumer *)subscribe:(RMQConsumerDeliveryHandler)handler;
/*!
 * @brief Perform an RMQChannel#basicConsume with the current queue's name.
 *        Pass an RMQConsumer instance to that method to customise cancellation behaviour.
 */
- (RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                   handler:(RMQConsumerDeliveryHandler)handler;

@end
