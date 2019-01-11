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

#import "RMQConsumer.h"
#import "RMQChannel.h"
#import "RMQMethods+Convenience.h"

@interface RMQConsumer ()
@property (nonatomic, readwrite) NSString *queueName;
@property (nonatomic, readwrite) RMQBasicConsumeOptions options;
@property (nonatomic, readwrite) NSString *tag;
@property (nonatomic, readwrite) id<RMQChannel> channel;
@property (nonatomic, readwrite) RMQConsumerDeliveryHandler deliveryHandler;
@property (nonatomic, readwrite) RMQConsumerCancellationHandler cancellationHandler;
@property (nonatomic, readwrite) RMQTable *arguments;
@end

@implementation RMQConsumer

- (instancetype)initWithChannel:(id<RMQChannel>)channel
                      queueName:(NSString *)queueName
                        options:(RMQBasicConsumeOptions)options {
    self = [super init];
    if (self) {
        self.queueName = queueName;
        self.options = options;
        self.arguments = [RMQTable new];
        self.tag = [channel generateConsumerTag];
        self.channel = channel;
        self.cancellationHandler = ^(){};
        self.deliveryHandler = ^(id _){};
    }
    return self;
}

- (instancetype)initWithChannel:(id<RMQChannel>)channel
                      queueName:(NSString *)queueName
                        options:(RMQBasicConsumeOptions)options
                      arguments:(RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.queueName = queueName;
        self.options = options;
        self.arguments = arguments;
        self.tag = [channel generateConsumerTag];
        self.channel = channel;
        self.cancellationHandler = ^(){};
        self.deliveryHandler = ^(id _){};
    }
    return self;
}

- (void)onDelivery:(RMQConsumerDeliveryHandler)handler {
    self.deliveryHandler = handler;
}

- (void)onCancellation:(RMQConsumerCancellationHandler)handler {
    self.cancellationHandler = handler;
}

- (void)consume:(RMQMessage *)message {
    self.deliveryHandler(message);
}

- (void)cancel {
    [self.channel basicCancel:self.tag];
}

- (void)handleCancellation {
    self.cancellationHandler();
}

- (BOOL)usesManualAckMode {
    return ![self usesAutomaticAckMode];
}

- (BOOL)usesAutomaticAckMode {
    return (self.options & RMQBasicConsumeNoAck) == RMQBasicConsumeNoAck;
}

- (BOOL)isExclusive {
    return (self.options & RMQBasicConsumeExclusive) == RMQBasicConsumeExclusive;
}

@end
