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

#import "RMQQueue.h"
#import "RMQMethods.h"
#import "RMQConnection.h"
#import "RMQBasicProperties.h"
#import "RMQChannel.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) RMQQueueDeclareOptions options;
@property (nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) id <RMQChannel> channel;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     options:(RMQQueueDeclareOptions)options
                   arguments:(RMQTable *)arguments
                     channel:(id<RMQChannel>)channel {
   self = [super init];
    if (self) {
        self.name = name;
        self.options = options;
        self.arguments = arguments;
        self.channel = channel;
    }
    return self;
}

- (nonnull instancetype)bind:(RMQExchange *)exchange
                  routingKey:(NSString *)routingKey {
    [self.channel queueBind:self.name exchange:exchange.name routingKey:routingKey];
    return self;
}

- (nonnull instancetype)bind:(RMQExchange *)exchange {
    [self bind:exchange routingKey:@""];
    return self;
}

- (nonnull instancetype)unbind:(RMQExchange *)exchange
                    routingKey:(NSString *)routingKey {
    [self.channel queueUnbind:self.name exchange:exchange.name routingKey:routingKey];
    return self;
}

- (nonnull instancetype)unbind:(RMQExchange *)exchange {
    [self unbind:exchange routingKey:@""];
    return self;
}

- (void)purge:(RMQQueuePurgeOptions)options {
    [self.channel queuePurge:self.name options:options];
}

- (void)purge {
    [self purge:RMQQueuePurgeNoOptions];
}

- (void)delete:(RMQQueueDeleteOptions)options {
    [self.channel queueDelete:self.name options:options];
}

- (void)delete {
    [self delete:RMQQueueDeleteNoOptions];
}

- (NSNumber *)publish:(NSData *)data
           properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties
              options:(RMQBasicPublishOptions)options {
    return [self.channel basicPublish:data
                           routingKey:self.name
                             exchange:@""
                           properties:properties
                              options:options];
}

- (NSNumber *)publish:(NSData *)body
           persistent:(BOOL)isPersistent
              options:(RMQBasicPublishOptions)options {
    NSMutableArray *properties = [NSMutableArray new];
    if (isPersistent) {
        [properties addObject:[[RMQBasicDeliveryMode alloc] init:2]];
    }
    return [self.channel basicPublish:body
                           routingKey:self.name
                             exchange:@""
                           properties:properties
                              options:options];
}

- (NSNumber *)publish:(NSData *)body
           persistent:(BOOL)isPersistent {
    return [self publish:body persistent:isPersistent options:RMQBasicPublishNoOptions];
}

- (NSNumber *)publish:(NSData *)body {
    return [self publish:body persistent:NO];
}

#pragma mark basic.get

- (void)pop:(RMQConsumerDeliveryHandler)handler {
    [self.channel basicGet:self.name
                   options:RMQBasicGetNoOptions
         completionHandler:handler];
}

#pragma mark Register a consumer

- (nonnull RMQConsumer *)subscribeAutoAcks:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                  acknowledgementMode:RMQBasicConsumeAcknowledgementModeAuto
                              handler:handler];
}

- (nonnull RMQConsumer *)subscribeManualAcks:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                  acknowledgementMode:RMQBasicConsumeAcknowledgementModeManual
                              handler:handler];
}

- (nonnull RMQConsumer *)subscribeWithAckMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                                      handler:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                  acknowledgementMode:acknowledgementMode
                              handler:handler];
}

- (nonnull RMQConsumer *)subscribeWithAckMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                                    arguments:(RMQTable *)arguments
                                      handler:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                  acknowledgementMode:acknowledgementMode
                            arguments:arguments
                              handler:handler];
}

- (nonnull RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                           handler:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                              options:options
                              handler:handler];
}

- (nonnull RMQConsumer *)subscribe:(RMQConsumerDeliveryHandler)handler {
    return [self subscribe:RMQBasicConsumeNoAck
                   handler:handler];
}

- (nonnull RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                         arguments:(RMQTable *)arguments
                           handler:(RMQConsumerDeliveryHandler)handler {
    return [self.channel basicConsume:self.name
                              options:options
                            arguments:arguments
                              handler:handler];
}
@end
