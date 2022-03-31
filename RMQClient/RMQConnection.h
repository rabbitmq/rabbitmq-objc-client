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

/// @brief Public API: Interface to an AMQP 0-9-1 connection. See the <a href="https://www.rabbitmq.com/specification.html">spec</a> for details.
@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender, RMQStarter, RMQTransportDelegate>

@property (nonnull, copy, nonatomic, readonly) NSString *vhost;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *serverProperties;

/// @brief Returns a GCD dispatch queue used for newly created connections by default.
+(nonnull dispatch_queue_t) defaultDispatchQueue;

/// @brief Designated initializer: do not use.
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                                   config:(nonnull RMQConnectionConfig *)config
                         handshakeTimeout:(nonnull NSNumber *)handshakeTimeout
                         channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                                 delegate:(nullable id<RMQConnectionDelegate>)delegate
                             commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
                            waiterFactory:(nonnull id<RMQWaiterFactory>)waiterFactory
                          heartbeatSender:(nonnull id<RMQHeartbeatSender>)heartbeatSender;

/// @brief Connection tuning, customisable config, all recovery options.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
         userProvidedConnectionName:(nonnull NSString *)connectionName
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                     connectTimeout:(nonnull NSNumber*)connectTimeout
                        readTimeout:(nonnull NSNumber*)readTimeout
                       writeTimeout:(nonnull NSNumber*)writeTimeout
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

/// @brief Connection tuning, customisable TLS, key recovery options.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

/// @brief Connection tuning, customisable TLS and connection name, key recovery options.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
         userProvidedConnectionName:(nullable NSString *)connectionName
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

/// @brief Connection tuning, customisable TLS, all recovery options.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
         userProvidedConnectionName:(nullable NSString *)connectionName
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

/// @brief Connection URI, custom name and delegate..
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
         userProvidedConnectionName:(nonnull NSString *)connectionName
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Connection URI, custom name, delegate object and delegate GCD queue.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
         userProvidedConnectionName:(nonnull NSString *)connectionName
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

/// @brief TLS, connection configuration and delegate.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
         userProvidedConnectionName:(nonnull NSString *)connectionName
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Allows setting of timeouts
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                     connectTimeout:(nonnull NSNumber*)connectTimeout
                        readTimeout:(nonnull NSNumber*)readTimeout
                       writeTimeout:(nonnull NSNumber*)writeTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Allows setting of recovery interval
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval;

/// @brief Allows setting of GCD queue
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

/// @brief Connection tuning options with customisable TLS
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                     connectTimeout:(nonnull NSNumber*)connectTimeout
                        readTimeout:(nonnull NSNumber*)readTimeout
                       writeTimeout:(nonnull NSNumber*)writeTimeout
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

/// @brief Connection tuning options.
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                     connectTimeout:(nonnull NSNumber*)connectTimeout
                        readTimeout:(nonnull NSNumber*)readTimeout
                       writeTimeout:(nonnull NSNumber*)writeTimeout
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

/*!
 * @brief Configurable TLS options. Use this if you wants TLS on a port other than 443.
 * @param uri        The URI contains all connection information, including credentials.<br/>
                     For example, "amqps://user:pass@hostname:1234/myvhost".<br/>
                     Note: to use the default "/" vhost, omit the trailing slash (or else you must encode it as %2F).
 * @param tlsOptions The RMQTLSOptions to use
 * @param delegate   Any object that conforms to the RMQConnectionDelegate protocol.
                     Use this to handle connection- and  channel-level errors.
                     RMQConnectionDelegateLogger is useful for development purposes.
 */
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/*!
 * @brief Parses URI to obtain credentials and TLS, customisable peer verification.
 * @param uri        The URI contains all connection information, including credentials.<br/>
                     For example, "amqps://user:pass@hostname:1234/myvhost".<br/>
                     Note: to use the default "/" vhost, omit the trailing slash (or else you must encode it as %2F).
 * @param verifyPeer Set to NO / false when developing against servers without valid certificates.
                     Never set this to NO / false in production.
 * @param delegate   Any object that conforms to the RMQConnectionDelegate protocol.
                     Use this to handle connection- and  channel-level errors.
                     RMQConnectionDelegateLogger is useful for development purposes.
 */
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         verifyPeer:(BOOL)verifyPeer
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/*!
 * @brief Parses URI to obtain credentials and TLS enablement (which implies verifyPeer).
 * @param uri        The URI contains all connection information, including credentials.<br/>
                     For example, "amqps://user:pass@hostname:1234/myvhost".<br/>
                     Note: to use the default "/" vhost, omit the trailing slash (or else you must encode it as %2F).
 * @param delegate   Any object that conforms to the RMQConnectionDelegate protocol.
                     Use this to handle connection- and  channel-level errors.
                     RMQConnectionDelegateLogger is useful for development purposes.
 */
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Assumes amqp://guest:guest@localhost URI.
- (nonnull instancetype)initWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;

/// @brief Returns the transport used by this connection, if any
-(nonnull id<RMQTransport>)transport;

/// @brief Returns true if the connection has successfully completed protocol handshake
- (BOOL)hasCompletedHandshake;

/// @brief Returns true if the connection is currently open
- (BOOL)isOpen;

/// @brief Returns true if the connection is currently closed
- (BOOL)isClosed;

/// @brief Close the connection.
- (void)close;

/// @brief Close the connection, blocking the calling thread until done.
- (void)blockingClose;

/*!
 * @brief Create a new channel, using an internally allocated channel number.
 * @return An RMQAllocatedChannel or RMQUnallocatedChannel. The latter sends errors to the RMQConnectionDelegate.
 */
- (nonnull id<RMQChannel>)createChannel;

@end
