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

#import "RMQExchange.h"
#import "RMQChannel.h"
#import "RMQBasicProperties.h"

@interface RMQExchange ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) RMQExchangeDeclareOptions options;
@property (nonatomic, readwrite) id<RMQChannel> channel;
@end

@implementation RMQExchange

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     options:(RMQExchangeDeclareOptions)options
                     channel:(id<RMQChannel>)channel {
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
        self.options = options;
        self.channel = channel;
    }
    return self;
}

- (nonnull instancetype)bind:(RMQExchange *)source
                  routingKey:(NSString *)routingKey {
    [self.channel exchangeBind:source.name
                   destination:self.name
                    routingKey:routingKey];
    return self;
}

- (nonnull instancetype)bind:(RMQExchange *)source {
    [self bind:source routingKey:@""];
    return self;
}

- (nonnull instancetype)unbind:(RMQExchange *)source
                    routingKey:(NSString *)routingKey {
    [self.channel exchangeUnbind:source.name
                     destination:self.name
                      routingKey:routingKey];
    return self;
}

- (nonnull instancetype)unbind:(RMQExchange *)source {
    [self unbind:source routingKey:@""];
    return self;
}

- (void)delete:(RMQExchangeDeleteOptions)options {
    [self.channel exchangeDelete:self.name options:options];
}

- (void)delete {
    [self delete:RMQExchangeDeleteNoOptions];
}

- (NSNumber *)publish:(NSData *)body
     routingKey:(NSString *)routingKey
     properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties
        options:(RMQBasicPublishOptions)options {
    return [self.channel basicPublish:body
                           routingKey:routingKey
                             exchange:self.name
                           properties:properties
                              options:options];
}

- (NSNumber *)publish:(NSData *)body
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent
        options:(RMQBasicPublishOptions)options {
    NSMutableArray *properties = [NSMutableArray new];
    if (isPersistent) {
        [properties addObject:[[RMQBasicDeliveryMode alloc] init:2]];
    }
    return [self.channel basicPublish:body
                           routingKey:key
                             exchange:self.name
                           properties:properties
                              options:options];
}

- (NSNumber *)publish:(NSData *)body
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent {
    return [self publish:body
              routingKey:key
              persistent:isPersistent
                 options:RMQBasicPublishNoOptions];
}

- (NSNumber *)publish:(NSData *)body
     routingKey:(NSString *)key {
    return [self publish:body
              routingKey:key
              persistent:NO];
}

- (NSNumber *)publish:(NSData *)body {
    return [self publish:body
              routingKey:@""];
}

@end
