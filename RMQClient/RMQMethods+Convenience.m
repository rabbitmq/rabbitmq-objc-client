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

#import "RMQMethods+Convenience.h"

RMQBasicConsumeOptions RMQBasicConsumeAcknowledgementModeToOptions(RMQBasicConsumeAcknowledgementMode mode) {
    if ((mode & RMQBasicConsumeAcknowledgementModeAuto) == RMQBasicConsumeAcknowledgementModeAuto) {
        return RMQBasicConsumeNoAck;
    } else {
        return RMQBasicConsumeNoOptions;
    };
}

@implementation RMQBasicConsume (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
                      options:(RMQBasicConsumeOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                       consumerTag:[[RMQShortstr alloc] init:consumerTag]
                           options:options
                         arguments:[RMQTable new]];
}

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
                      options:(RMQBasicConsumeOptions)options
                      arguments:(RMQTable *)arguments {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                       consumerTag:[[RMQShortstr alloc] init:consumerTag]
                           options:options
                         arguments:arguments];
}

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
          acknowledgementMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode {


    return [self initWithQueue:queueName
                   consumerTag:consumerTag
                       options:RMQBasicConsumeAcknowledgementModeToOptions(acknowledgementMode)];
}

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
          acknowledgementMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                    arguments:(RMQTable *)arguments{
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                       consumerTag:[[RMQShortstr alloc] init:consumerTag]
                           options:RMQBasicConsumeAcknowledgementModeToOptions(acknowledgementMode)
                         arguments:arguments];
}

@end

@implementation RMQBasicQos (Convenience)

- (instancetype)initWithPrefetchCount:(NSNumber *)prefetchCount
                               global:(BOOL)isGlobal {
    RMQBasicQosOptions options = RMQBasicQosNoOptions;
    if (isGlobal) options     |= RMQBasicQosGlobal;

    return [self initWithPrefetchSize:[[RMQLong alloc] init:0]
                        prefetchCount:[[RMQShort alloc] init:prefetchCount.integerValue]
                              options:options];
}

@end

@implementation RMQChannelOpen (Convenience)

- (instancetype)init {
    return [self initWithReserved1:[[RMQShortstr alloc] init:@""]];
}

@end

@implementation RMQChannelClose (Convenience)

- (instancetype)init {
    return [self initWithReplyCode:[[RMQShort alloc] init:200]
                         replyText:[[RMQShortstr alloc] init:@"Goodbye"]
                           classId:[[RMQShort alloc] init:0]
                          methodId:[[RMQShort alloc] init:0]];
}

@end

@implementation RMQConfirmSelect (Convenience)

- (instancetype)init {
    return [self initWithOptions:RMQConfirmSelectNoOptions];
}

@end

@implementation RMQExchangeBind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                       destination:[[RMQShortstr alloc] init:destination]
                            source:[[RMQShortstr alloc] init:source]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQExchangeBindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQExchangeDeclare (Convenience)

- (instancetype)initWithExchange:(NSString *)exchangeName
                            type:(NSString *)type
                         options:(RMQExchangeDeclareOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                              type:[[RMQShortstr alloc] init:type]
                           options:options
                         arguments:[RMQTable new]];
}

@end

@implementation RMQExchangeUnbind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                       destination:[[RMQShortstr alloc] init:destination]
                            source:[[RMQShortstr alloc] init:source]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQExchangeUnbindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQQueueBind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQQueueBindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQQueueDeclare (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeclareOptions)options
                    arguments:(RMQTable *)arguments {
    RMQShort *ticket          = [[RMQShort alloc] init:0];
    RMQShortstr *amqQueueName = [[RMQShortstr alloc] init:queueName];

    return [self initWithReserved1:ticket
                             queue:amqQueueName
                           options:options
                         arguments:arguments];
}

@end

@implementation RMQQueuePurge (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueuePurgeOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                           options:options];
}

@end

@implementation RMQQueueDelete (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeleteOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                           options:options];
}

@end

@implementation RMQQueueUnbind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                         arguments:[RMQTable new]];
}

@end
