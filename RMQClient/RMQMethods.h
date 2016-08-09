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

// This file is generated. Do not edit.
#import <Foundation/Foundation.h>
#import "RMQTable.h"

@interface RMQConnectionStart : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readonly) RMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readonly) RMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *locales;
- (nonnull instancetype)initWithVersionMajor:(nonnull RMQOctet *)versionMajor
                                versionMinor:(nonnull RMQOctet *)versionMinor
                            serverProperties:(nonnull RMQTable *)serverProperties
                                  mechanisms:(nonnull RMQLongstr *)mechanisms
                                     locales:(nonnull RMQLongstr *)locales;
@end

@interface RMQConnectionStartOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *response;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *locale;
- (nonnull instancetype)initWithClientProperties:(nonnull RMQTable *)clientProperties
                                       mechanism:(nonnull RMQShortstr *)mechanism
                                        response:(nonnull RMQLongstr *)response
                                          locale:(nonnull RMQShortstr *)locale;
@end

@interface RMQConnectionSecure : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *challenge;
- (nonnull instancetype)initWithChallenge:(nonnull RMQLongstr *)challenge;
@end

@interface RMQConnectionSecureOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *response;
- (nonnull instancetype)initWithResponse:(nonnull RMQLongstr *)response;
@end

@interface RMQConnectionTune : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) RMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat;
@end

@interface RMQConnectionTuneOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) RMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat;
@end

typedef NS_OPTIONS(NSUInteger, RMQConnectionOpenOptions) {
    RMQConnectionOpenNoOptions = 0,
    /// @brief
    RMQConnectionOpenReserved2 = 1 << 0,
};

@interface RMQConnectionOpen : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
@property (nonatomic, readonly) RMQConnectionOpenOptions options;
- (nonnull instancetype)initWithVirtualHost:(nonnull RMQShortstr *)virtualHost
                                  reserved1:(nonnull RMQShortstr *)reserved1
                                    options:(RMQConnectionOpenOptions)options;
@end

@interface RMQConnectionOpenOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end

@interface RMQConnectionClose : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) RMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId;
@end

@interface RMQConnectionCloseOk : RMQValue <RMQMethod>

@end

@interface RMQConnectionBlocked : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reason;
- (nonnull instancetype)initWithReason:(nonnull RMQShortstr *)reason;
@end

@interface RMQConnectionUnblocked : RMQValue <RMQMethod>

@end

@interface RMQChannelOpen : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end

@interface RMQChannelOpenOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQLongstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, RMQChannelFlowOptions) {
    RMQChannelFlowNoOptions = 0,
    /// @brief If 1, the peer starts sending content frames. If 0, the peer stops sending content frames.
    RMQChannelFlowActive    = 1 << 0,
};

@interface RMQChannelFlow : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQChannelFlowOptions options;
- (nonnull instancetype)initWithOptions:(RMQChannelFlowOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, RMQChannelFlowOkOptions) {
    RMQChannelFlowOkNoOptions = 0,
    /// @brief Confirms the setting of the processed flow method: 1 means the peer will start sending or continue to send content frames; 0 means it will not.
    RMQChannelFlowOkActive    = 1 << 0,
};

@interface RMQChannelFlowOk : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQChannelFlowOkOptions options;
- (nonnull instancetype)initWithOptions:(RMQChannelFlowOkOptions)options;
@end

@interface RMQChannelClose : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) RMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId;
@end

@interface RMQChannelCloseOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQExchangeDeclareOptions) {
    RMQExchangeDeclareNoOptions  = 0,
    /// @brief If set, the server will reply with Declare-Ok if the exchange already exists with the same name, and raise an error if not. The client can use this to check whether an exchange exists without modifying the server state. When set, all other method fields except name and no-wait are ignored. A declare with both passive and no-wait has no effect. Arguments are compared for semantic equivalence.
    RMQExchangeDeclarePassive    = 1 << 0,
    /// @brief If set when creating a new exchange, the exchange will be marked as durable. Durable exchanges remain active when a server restarts. Non-durable exchanges (transient exchanges) are purged if/when a server restarts.
    RMQExchangeDeclareDurable    = 1 << 1,
    /// @brief If set, the exchange is deleted when all queues have finished using it.
    RMQExchangeDeclareAutoDelete = 1 << 2,
    /// @brief If set, the exchange may not be used directly by publishers, but only when bound to other exchanges. Internal exchanges are used to construct wiring that is not visible to applications.
    RMQExchangeDeclareInternal   = 1 << 3,
    /// @brief
    RMQExchangeDeclareNoWait     = 1 << 4,
};

@interface RMQExchangeDeclare : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *type;
@property (nonatomic, readonly) RMQExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                     type:(nonnull RMQShortstr *)type
                                  options:(RMQExchangeDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQExchangeDeclareOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQExchangeDeleteOptions) {
    RMQExchangeDeleteNoOptions = 0,
    /// @brief If set, the server will only delete the exchange if it has no queue bindings. If the exchange has queue bindings the server does not delete it but raises a channel exception instead.
    RMQExchangeDeleteIfUnused  = 1 << 0,
    /// @brief
    RMQExchangeDeleteNoWait    = 1 << 1,
};

@interface RMQExchangeDelete : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonatomic, readonly) RMQExchangeDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                  options:(RMQExchangeDeleteOptions)options;
@end

@interface RMQExchangeDeleteOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQExchangeBindOptions) {
    RMQExchangeBindNoOptions = 0,
    /// @brief
    RMQExchangeBindNoWait    = 1 << 0,
};

@interface RMQExchangeBind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeBindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQExchangeBindOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQExchangeUnbindOptions) {
    RMQExchangeUnbindNoOptions = 0,
    /// @brief
    RMQExchangeUnbindNoWait    = 1 << 0,
};

@interface RMQExchangeUnbind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeUnbindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQExchangeUnbindOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQQueueDeclareOptions) {
    RMQQueueDeclareNoOptions  = 0,
    /// @brief If set, the server will reply with Declare-Ok if the queue already exists with the same name, and raise an error if not. The client can use this to check whether a queue exists without modifying the server state. When set, all other method fields except name and no-wait are ignored. A declare with both passive and no-wait has no effect. Arguments are compared for semantic equivalence.
    RMQQueueDeclarePassive    = 1 << 0,
    /// @brief If set when creating a new queue, the queue will be marked as durable. Durable queues remain active when a server restarts. Non-durable queues (transient queues) are purged if/when a server restarts. Note that durable queues do not necessarily hold persistent messages, although it does not make sense to send persistent messages to a transient queue.
    RMQQueueDeclareDurable    = 1 << 1,
    /// @brief Exclusive queues may only be accessed by the current connection, and are deleted when that connection closes. Passive declaration of an exclusive queue by other connections are not allowed.
    RMQQueueDeclareExclusive  = 1 << 2,
    /// @brief If set, the queue is deleted when all consumers have finished using it. The last consumer can be cancelled either explicitly or because its channel is closed. If there was no consumer ever on the queue, it won't be deleted. Applications can explicitly delete auto-delete queues using the Delete method as normal.
    RMQQueueDeclareAutoDelete = 1 << 3,
    /// @brief
    RMQQueueDeclareNoWait     = 1 << 4,
};

@interface RMQQueueDeclare : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQQueueDeclareOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
@property (nonnull, copy, nonatomic, readonly) RMQLong *consumerCount;
- (nonnull instancetype)initWithQueue:(nonnull RMQShortstr *)queue
                         messageCount:(nonnull RMQLong *)messageCount
                        consumerCount:(nonnull RMQLong *)consumerCount;
@end

typedef NS_OPTIONS(NSUInteger, RMQQueueBindOptions) {
    RMQQueueBindNoOptions = 0,
    /// @brief
    RMQQueueBindNoWait    = 1 << 0,
};

@interface RMQQueueBind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQQueueBindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQQueueBindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQQueueBindOk : RMQValue <RMQMethod>

@end

@interface RMQQueueUnbind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQQueueUnbindOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQQueuePurgeOptions) {
    RMQQueuePurgeNoOptions = 0,
    /// @brief
    RMQQueuePurgeNoWait    = 1 << 0,
};

@interface RMQQueuePurge : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueuePurgeOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueuePurgeOptions)options;
@end

@interface RMQQueuePurgeOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, RMQQueueDeleteOptions) {
    RMQQueueDeleteNoOptions = 0,
    /// @brief If set, the server will only delete the queue if it has no consumers. If the queue has consumers the server does does not delete it but raises a channel exception instead.
    RMQQueueDeleteIfUnused  = 1 << 0,
    /// @brief If set, the server will only delete the queue if it has no messages.
    RMQQueueDeleteIfEmpty   = 1 << 1,
    /// @brief
    RMQQueueDeleteNoWait    = 1 << 2,
};

@interface RMQQueueDelete : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueueDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeleteOptions)options;
@end

@interface RMQQueueDeleteOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicQosOptions) {
    RMQBasicQosNoOptions = 0,
    /// @brief RabbitMQ has reinterpreted this field. The original specification said: "By default the QoS settings apply to the current channel only. If this field is set, they are applied to the entire connection." Instead, RabbitMQ takes global=false to mean that the QoS settings should apply per-consumer (for new consumers on the channel; existing ones being unaffected) and global=true to mean that the QoS settings should apply per-channel.
    RMQBasicQosGlobal    = 1 << 0,
};

@interface RMQBasicQos : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readonly) RMQShort *prefetchCount;
@property (nonatomic, readonly) RMQBasicQosOptions options;
- (nonnull instancetype)initWithPrefetchSize:(nonnull RMQLong *)prefetchSize
                               prefetchCount:(nonnull RMQShort *)prefetchCount
                                     options:(RMQBasicQosOptions)options;
@end

@interface RMQBasicQosOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQBasicConsumeOptions) {
    RMQBasicConsumeNoOptions = 0,
    /// @brief
    RMQBasicConsumeNoLocal   = 1 << 0,
    /// @brief
    RMQBasicConsumeNoAck     = 1 << 1,
    /// @brief Request exclusive consumer access, meaning only this consumer can access the queue.
    RMQBasicConsumeExclusive = 1 << 2,
    /// @brief
    RMQBasicConsumeNoWait    = 1 << 3,
};

@interface RMQBasicConsume : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonatomic, readonly) RMQBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                              consumerTag:(nonnull RMQShortstr *)consumerTag
                                  options:(RMQBasicConsumeOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end

@interface RMQBasicConsumeOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicCancelOptions) {
    RMQBasicCancelNoOptions = 0,
    /// @brief
    RMQBasicCancelNoWait    = 1 << 0,
};

@interface RMQBasicCancel : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonatomic, readonly) RMQBasicCancelOptions options;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                    options:(RMQBasicCancelOptions)options;
@end

@interface RMQBasicCancelOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicPublishOptions) {
    RMQBasicPublishNoOptions = 0,
    /// @brief This flag tells the server how to react if the message cannot be routed to a queue. If this flag is set, the server will return an unroutable message with a Return method. If this flag is zero, the server silently drops the message.
    RMQBasicPublishMandatory = 1 << 0,
};

@interface RMQBasicPublish : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQBasicPublishOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQBasicPublishOptions)options;
@end

@interface RMQBasicReturn : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicDeliverOptions) {
    RMQBasicDeliverNoOptions   = 0,
    /// @brief
    RMQBasicDeliverRedelivered = 1 << 0,
};

@interface RMQBasicDeliver : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                deliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicDeliverOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicGetOptions) {
    RMQBasicGetNoOptions = 0,
    /// @brief
    RMQBasicGetNoAck     = 1 << 0,
};

@interface RMQBasicGet : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQBasicGetOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQBasicGetOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicGetOkOptions) {
    RMQBasicGetOkNoOptions   = 0,
    /// @brief
    RMQBasicGetOkRedelivered = 1 << 0,
};

@interface RMQBasicGetOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicGetOkOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey
                               messageCount:(nonnull RMQLong *)messageCount;
@end

@interface RMQBasicGetEmpty : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicAckOptions) {
    RMQBasicAckNoOptions = 0,
    /// @brief If set to 1, the delivery tag is treated as "up to and including", so that multiple messages can be acknowledged with a single method. If set to zero, the delivery tag refers to a single message. If the multiple field is 1, and the delivery tag is zero, this indicates acknowledgement of all outstanding messages.
    RMQBasicAckMultiple  = 1 << 0,
};

@interface RMQBasicAck : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicAckOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicAckOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicRejectOptions) {
    RMQBasicRejectNoOptions = 0,
    /// @brief If requeue is true, the server will attempt to requeue the message. If requeue is false or the requeue attempt fails the messages are discarded or dead-lettered.
    RMQBasicRejectRequeue   = 1 << 0,
};

@interface RMQBasicReject : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicRejectOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicRejectOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicRecoverAsyncOptions) {
    RMQBasicRecoverAsyncNoOptions = 0,
    /// @brief If this field is zero, the message will be redelivered to the original recipient. If this bit is 1, the server will attempt to requeue the message, potentially then delivering it to an alternative subscriber.
    RMQBasicRecoverAsyncRequeue   = 1 << 0,
};

@interface RMQBasicRecoverAsync : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQBasicRecoverAsyncOptions options;
- (nonnull instancetype)initWithOptions:(RMQBasicRecoverAsyncOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, RMQBasicRecoverOptions) {
    RMQBasicRecoverNoOptions = 0,
    /// @brief If this field is zero, the message will be redelivered to the original recipient. If this bit is 1, the server will attempt to requeue the message, potentially then delivering it to an alternative subscriber.
    RMQBasicRecoverRequeue   = 1 << 0,
};

@interface RMQBasicRecover : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQBasicRecoverOptions options;
- (nonnull instancetype)initWithOptions:(RMQBasicRecoverOptions)options;
@end

@interface RMQBasicRecoverOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQBasicNackOptions) {
    RMQBasicNackNoOptions = 0,
    /// @brief If set to 1, the delivery tag is treated as "up to and including", so that multiple messages can be rejected with a single method. If set to zero, the delivery tag refers to a single message. If the multiple field is 1, and the delivery tag is zero, this indicates rejection of all outstanding messages.
    RMQBasicNackMultiple  = 1 << 0,
    /// @brief If requeue is true, the server will attempt to requeue the message. If requeue is false or the requeue attempt fails the messages are discarded or dead-lettered. Clients receiving the Nack methods should ignore this flag.
    RMQBasicNackRequeue   = 1 << 1,
};

@interface RMQBasicNack : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicNackOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicNackOptions)options;
@end

@interface RMQTxSelect : RMQValue <RMQMethod>

@end

@interface RMQTxSelectOk : RMQValue <RMQMethod>

@end

@interface RMQTxCommit : RMQValue <RMQMethod>

@end

@interface RMQTxCommitOk : RMQValue <RMQMethod>

@end

@interface RMQTxRollback : RMQValue <RMQMethod>

@end

@interface RMQTxRollbackOk : RMQValue <RMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, RMQConfirmSelectOptions) {
    RMQConfirmSelectNoOptions = 0,
    /// @brief If set, the server will not respond to the method. The client should not wait for a reply method. If the server could not complete the method it will raise a channel or connection exception.
    RMQConfirmSelectNowait    = 1 << 0,
};

@interface RMQConfirmSelect : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQConfirmSelectOptions options;
- (nonnull instancetype)initWithOptions:(RMQConfirmSelectOptions)options;
@end

@interface RMQConfirmSelectOk : RMQValue <RMQMethod>

@end

