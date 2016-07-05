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

@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;

- (void)activateWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;
- (void)open;
- (void)close;
- (void)blockingClose;
- (void)prepareForRecovery;
- (void)recover;
- (void)blockingWaitOn:(nonnull Class)method;
- (void)confirmSelect;
- (void)afterConfirmed:(void (^ _Nonnull)(NSSet<NSNumber *> * _Nonnull acked, NSSet<NSNumber *> * _Nonnull nacked))handler;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options
                  arguments:(nonnull NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)arguments;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (void)queueDelete:(nonnull NSString *)queueName
            options:(RMQQueueDeleteOptions)options;

- (void)queueBind:(nonnull NSString *)queueName
         exchange:(nonnull NSString *)exchangeName
       routingKey:(nonnull NSString *)routingKey;

- (void)queueUnbind:(nonnull NSString *)queueName
           exchange:(nonnull NSString *)exchangeName
         routingKey:(nonnull NSString *)routingKey;

- (nonnull RMQConsumer *)basicConsume:(nonnull NSString *)queueName
                              options:(RMQBasicConsumeOptions)options
                              handler:(RMQConsumerDeliveryHandler _Nonnull)handler;

- (void)basicCancel:(nonnull NSString *)consumerTag;

- (void)basicPublish:(nonnull NSData *)body
          routingKey:(nonnull NSString *)routingKey
            exchange:(nonnull NSString *)exchange
          properties:(nonnull NSArray<RMQValue *> *)properties
             options:(RMQBasicPublishOptions)options;

-  (void)basicGet:(nonnull NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumerDeliveryHandler _Nonnull)completionHandler;

- (void)basicQos:(nonnull NSNumber *)count
          global:(BOOL)isGlobal;

- (void)ack:(nonnull NSNumber *)deliveryTag
    options:(RMQBasicAckOptions)options;

- (void)ack:(nonnull NSNumber *)deliveryTag;

- (void)reject:(nonnull NSNumber *)deliveryTag
       options:(RMQBasicRejectOptions)options;

- (void)reject:(nonnull NSNumber *)deliveryTag;

- (void)nack:(nonnull NSNumber *)deliveryTag
     options:(RMQBasicNackOptions)options;

- (void)nack:(nonnull NSNumber *)deliveryTag;

- (nonnull RMQExchange *)defaultExchange;

- (nonnull RMQExchange *)fanout:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)fanout:(nonnull NSString *)name;

- (nonnull RMQExchange *)direct:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)direct:(nonnull NSString *)name;

- (nonnull RMQExchange *)topic:(nonnull NSString *)name
                       options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)topic:(nonnull NSString *)name;

- (nonnull RMQExchange *)headers:(nonnull NSString *)name
                         options:(RMQExchangeDeclareOptions)options;
- (nonnull RMQExchange *)headers:(nonnull NSString *)name;

- (void)exchangeDeclare:(nonnull NSString *)name
                   type:(nonnull NSString *)type
                options:(RMQExchangeDeclareOptions)options;

- (void)exchangeBind:(nonnull NSString *)sourceName
         destination:(nonnull NSString *)destinationName
          routingKey:(nonnull NSString *)routingKey;

- (void)exchangeUnbind:(nonnull NSString *)sourceName
           destination:(nonnull NSString *)destinationName
            routingKey:(nonnull NSString *)routingKey;

- (void)exchangeDelete:(nonnull NSString *)name
               options:(RMQExchangeDeleteOptions)options;

@end
