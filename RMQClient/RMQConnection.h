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
#import "RMQValues.h"
#import "RMQChannel.h"
#import "RMQChannelAllocator.h"
#import "RMQConnectionDelegate.h"
#import "RMQFrameHandler.h"
#import "RMQHeartbeatSender.h"
#import "RMQSender.h"
#import "RMQTransport.h"
#import "RMQLocalSerialQueue.h"
#import "RMQWaiterFactory.h"
#import "RMQTLSOptions.h"
#import "RMQStarter.h"

extern NSInteger const RMQChannelLimit;

@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender, RMQStarter, RMQTransportDelegate>

@property (nonnull, copy, nonatomic, readonly) NSString *vhost;

# pragma mark - Designated initializer (implementation only)
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                                   config:(nonnull RMQConnectionConfig *)config
                         handshakeTimeout:(nonnull NSNumber *)handshakeTimeout
                         channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                                 delegate:(nullable id<RMQConnectionDelegate>)delegate
                             commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
                            waiterFactory:(nonnull id<RMQWaiterFactory>)waiterFactory
                          heartbeatSender:(nonnull id<RMQHeartbeatSender>)heartbeatSender;

# pragma mark - User-facing initializers
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         verifyPeer:(BOOL)verifyPeer
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;

# pragma mark - Other methods
- (void)close;
- (void)blockingClose;
- (nonnull id<RMQChannel>)createChannel;

@end
