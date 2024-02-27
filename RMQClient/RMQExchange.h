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
#import "RMQBasicProperties.h"

@protocol RMQChannel;

/*!
 * @brief Interface to an exchange.
 * All operations delegate to the associated RMQChannel.
 */
@interface RMQExchange : NSObject

@property (nonnull, nonatomic, readonly) NSString *name;
@property (nonnull, nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) RMQExchangeDeclareOptions options;

/// @brief Internal constructor used by RMQChannel exchange creation methods (direct, fanout, topic, headers)
- (instancetype _Nonnull )initWithName:(nonnull NSString *)name
                                  type:(nonnull NSString *)type
                               options:(RMQExchangeDeclareOptions)options
                               channel:(nonnull id<RMQChannel>)channel;

/// @brief Bind this exchange to another exchange
- (nonnull instancetype)bind:(nonnull RMQExchange *)source
                  routingKey:(NSString *_Nullable)routingKey;
/// @brief Bind this exchange to another exchange
- (nonnull instancetype)bind:(nonnull RMQExchange *)source;
/// @brief Unbind this exchange from another exchange
- (nonnull instancetype)unbind:(nonnull RMQExchange *)source
                    routingKey:(NSString *_Nullable)routingKey;
/// @brief Unbind this exchange from another exchange
- (nonnull instancetype)unbind:(nonnull RMQExchange *)source;
/// @brief Delete the exchange
- (void)delete:(RMQExchangeDeleteOptions)options;
/// @brief Delete the exchange with no options
- (void)delete;
/*!
 * @brief  Publish a message to this exchange
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   routingKey:(nonnull NSString *)routingKey
                   properties:(NSArray <RMQValue<RMQBasicValue> *> *_Nonnull)properties
                      options:(RMQBasicPublishOptions)options;
/*!
 * @brief  Publish a message to this exchange
 *         Convenience method for setting persistent property and no other properties.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   routingKey:(nonnull NSString *)key
                   persistent:(BOOL)isPersistent
                      options:(RMQBasicPublishOptions)options;
/*!
 * @brief  Publish a message to this exchange
 *         Convenience method for setting persistent property and no other properties or options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   routingKey:(nonnull NSString *)key
                   persistent:(BOOL)isPersistent;
/*!
 * @brief  Publish a message to this exchange
 *         Convenience method for publishing without persistence or any other properties / options.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body
                   routingKey:(nonnull NSString *)key;
/*!
 * @brief  Publish a message to this exchange
 *         Convenience method for publishing without properties, options or routing key.
 * @return Sequence number corresponding to the numbers passed to RMQChannel#afterConfirmed
 */
- (nonnull NSNumber *)publish:(nonnull NSData *)body;

@end
