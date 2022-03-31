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

#import "RMQUnallocatedChannel.h"
#import "RMQErrors.h"
#import "RMQConnectionDelegate.h"

@interface RMQUnallocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQUnallocatedChannel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelNumber = @(-1);
    }
    return self;
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
}

- (void)open {}

- (BOOL)isOpen {
    return FALSE;
}

- (BOOL)isClosed {
    return !self.isOpen;
}

- (BOOL)wasClosedByServer {
    return FALSE;
}

- (BOOL)wasClosedExplicitly {
    return FALSE;
}

- (void)close {}

- (void)close:(RMQChannelCompletionHandler)handler {}

- (void)blockingClose {}

- (void)prepareForRecovery {}

- (void)recover {}

- (void)blockingWaitOn:(Class)method {
    [self err];
}

- (void)confirmSelect {
    [self err];
}

- (void)afterConfirmed:(NSNumber *)timeout
               handler:(void (^)(NSSet<NSNumber *> * _Nonnull, NSSet<NSNumber *> * _Nonnull))handler {
    [self err];
}

- (void)afterConfirmed:(void (^)(NSSet<NSNumber *> * _Nonnull, NSSet<NSNumber *> * _Nonnull))handler {
    [self afterConfirmed:@0 handler:handler];
}

- (RMQConsumer *)basicConsume:(NSString *)queueName
          acknowledgementMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                      handler:(RMQConsumerDeliveryHandler)handler {
    [self err];
    return nil;
}

- (RMQConsumer *)basicConsume:(NSString *)queueName
                      options:(RMQBasicConsumeOptions)options
                      handler:(RMQConsumerDeliveryHandler)handler {
    [self basicConsume:[[RMQConsumer alloc] initWithChannel:self queueName:queueName options:options]];
    return nil;
}

- (void)basicConsume:(RMQConsumer *)consumer {
    [self err];
}

/*!
 * @brief Consume messages from a queue
 * @see RMQQueue's subscribe method (which has variants with defaults)
 */
- (nonnull RMQConsumer *)basicConsume:(nonnull NSString *)queueName
                              options:(RMQBasicConsumeOptions)options
                            arguments:(RMQTable * _Nonnull)arguments
                              handler:(RMQConsumerDeliveryHandler _Nonnull)handler {
    [self err];
    return nil;
}

- (RMQConsumer *)basicConsume:(NSString *)queueName
          acknowledgementMode:(RMQBasicConsumeAcknowledgementMode)acknowledgementMode
                    arguments:(RMQTable *)arguments
                      handler:(RMQConsumerDeliveryHandler)handler {
    [self err];
    return nil;
}

- (NSString *)generateConsumerTag {
    [self err];
    return nil;
}

- (void)basicCancel:(NSString *)consumerTag {
}

- (NSNumber *)basicPublish:(NSString *)message
                routingKey:(NSString *)routingKey
                  exchange:(NSString *)exchange
                properties:(NSArray *)properties
                   options:(RMQBasicPublishOptions)options {
    [self err];
    return @-1;
}

-  (void)basicGet:(NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumerDeliveryHandler)completionHandler {
    [self err];
}

- (void)basicRecover
{
    [self err];
}

- (RMQExchange *)defaultExchange {
    [self err];
    return nil;
}

- (RMQQueue *)queue:(NSString *)queueName options:(RMQQueueDeclareOptions)options arguments:(nonnull NSDictionary *)arguments {
    [self err];
    return nil;
}

- (RMQQueue *)queue:(NSString *)queueName options:(RMQQueueDeclareOptions)options {
    return [self queue:queueName options:options arguments:@{}];
}

- (RMQQueue *)queue:(NSString *)queueName {
    return [self queue:queueName options:RMQQueueDeclareNoOptions];
}

- (void)queuePurge:(NSString *)queueName
           options:(RMQQueuePurgeOptions)options {
    [self err];
}

- (void)queueDelete:(NSString *)queueName
            options:(RMQQueueDeleteOptions)options {
    [self err];
}

- (void)queueBind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(nonnull NSString *)routingKey {
    [self err];
}

- (void)queueUnbind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(NSString *)routingKey {
    [self err];
}

- (void)handleFrameset:(RMQFrameset *)frameset {
}

- (void)basicQos:(NSNumber *)count
          global:(BOOL)isGlobal {
    [self err];
}

- (void)ack:(NSNumber *)deliveryTag options:(RMQBasicAckOptions)options {
    [self err];
}

- (void)ack:(NSNumber *)deliveryTag {
    [self ack:deliveryTag options:RMQBasicAckNoOptions];
}

- (void)reject:(NSNumber *)deliveryTag options:(RMQBasicRejectOptions)options {
    [self err];
}

- (void)reject:(NSNumber *)deliveryTag {
    [self reject:deliveryTag options:RMQBasicRejectNoOptions];
}

- (void)nack:(NSNumber *)deliveryTag options:(RMQBasicNackOptions)options {
    [self err];
}

- (void)nack:(NSNumber *)deliveryTag {
    [self nack:deliveryTag options:RMQBasicNackNoOptions];
}

- (void)exchangeDeclare:(NSString *)name type:(NSString *)type options:(RMQExchangeDeclareOptions)options {
    [self err];
}

- (void)exchangeBind:(NSString *)sourceName
         destination:(NSString *)destinationName
          routingKey:(NSString *)routingKey {
    [self err];
}

- (void)exchangeUnbind:(NSString *)sourceName
           destination:(NSString *)destinationName
            routingKey:(NSString *)routingKey {
    [self err];
}

- (RMQExchange *)fanout:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)fanout:(NSString *)name {
    return [self fanout:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)direct:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)direct:(NSString *)name {
    return [self direct:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)topic:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)topic:(NSString *)name {
    return [self topic:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)headers:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)headers:(NSString *)name {
    return [self headers:name options:RMQExchangeDeclareNoOptions];
}

- (void)exchangeDelete:(NSString *)name
               options:(RMQExchangeDeleteOptions)options {
    [self err];
}

# pragma mark - Private

- (void)err {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain code:RMQErrorChannelUnallocated userInfo:@{NSLocalizedDescriptionKey: @"Unallocated channel"}];
    [self.delegate channel:self error:error];
}

@end
