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

#import "RMQConnectionDefaults.h"
#import "RMQConnection.h"
#import "RMQConnectionRecover.h"
#import "RMQGCDHeartbeatSender.h"
#import "RMQGCDSerialQueue.h"
#import "RMQHandshaker.h"
#import "RMQMethods.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQProtocolHeader.h"
#import "RMQQueuingConnectionDelegateProxy.h"
#import "RMQReader.h"
#import "RMQSemaphoreWaiterFactory.h"
#import "RMQTCPSocketTransport.h"
#import "RMQURI.h"
#import "RMQTickingClock.h"
#import "RMQTLSOptions.h"
#import "RMQErrors.h"
#import "RMQFrame.h"
#import "RMQProcessInfoNameGenerator.h"

@interface RMQConnection ()
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) RMQReader *reader;
@property (nonatomic, readwrite) id <RMQChannelAllocator> channelAllocator;
@property (nonatomic, readwrite) id <RMQFrameHandler> frameHandler;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQWaiterFactory> waiterFactory;
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@property (nonatomic, weak, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) id <RMQChannel> channelZero;
@property (nonatomic, readwrite) RMQConnectionConfig *config;
@property (nonatomic, readwrite) NSMutableDictionary *userChannels;
@property (nonatomic, readwrite) NSNumber *frameMax;
@property (nonatomic, readwrite) BOOL handshakeComplete;
@property (nonatomic, readwrite) NSNumber *handshakeTimeout;
@end

__attribute__((constructor))
static void RMQInitConnectionConfigDefaults() {
    RMQDefaultHeartbeatTimeout = [NSNumber numberWithInteger:60];
    RMQDefaultConnectTimeout   = [NSNumber numberWithInteger:30];
    RMQDefaultReadTimeout      = [NSNumber numberWithInteger:55];
    RMQDefaultWriteTimeout     = [NSNumber numberWithInteger:55];

    RMQDefaultSyncTimeout      = [NSNumber numberWithInteger:15];
    RMQDefaultRecoveryInterval = [NSNumber numberWithInteger:4];
}

@implementation RMQConnection

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                           config:(RMQConnectionConfig *)config
                 handshakeTimeout:(NSNumber *)handshakeTimeout
                 channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                     frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                         delegate:(id<RMQConnectionDelegate>)delegate
                     commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
                    waiterFactory:(nonnull id<RMQWaiterFactory>)waiterFactory
                  heartbeatSender:(nonnull id<RMQHeartbeatSender>)heartbeatSender {
    self = [super init];
    if (self) {
        self.config = config;
        self.handshakeComplete = NO;
        self.handshakeTimeout = handshakeTimeout;
        self.frameMax = config.frameMax;
        self.transport = transport;
        self.transport.delegate = self;
        self.channelAllocator = channelAllocator;
        self.channelAllocator.sender = self;
        self.frameHandler = frameHandler;
        self.reader = [[RMQReader alloc] initWithTransport:self.transport frameHandler:self];

        self.userChannels = [NSMutableDictionary new];
        self.delegate = delegate;
        self.commandQueue = commandQueue;
        self.waiterFactory = waiterFactory;
        self.heartbeatSender = heartbeatSender;

        self.channelZero = [self.channelAllocator allocate];
        [self.channelZero activateWithDelegate:self.delegate];
    }
    return self;
}

- (nonnull instancetype)initWithUri:(NSString *)uri
                         tlsOptions:(RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                     connectTimeout:(nonnull NSNumber*)connectTimeout
                        readTimeout:(nonnull NSNumber*)readTimeout
                       writeTimeout:(nonnull NSNumber*)writeTimeout
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(id<RMQConnectionDelegate>)delegate
                      delegateQueue:(dispatch_queue_t)delegateQueue
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose {
    NSError *error = NULL;
    RMQURI *rmqURI = [RMQURI parse:uri error:&error];

    RMQTCPSocketTransport *transport = [[RMQTCPSocketTransport alloc] initWithHost:rmqURI.host
                                                                              port:rmqURI.portNumber
                                                                        tlsOptions:tlsOptions
                                                                    connectTimeout:connectTimeout
                                                                       readTimeout:readTimeout
                                                                      writeTimeout:writeTimeout];
    RMQMultipleChannelAllocator *allocator = [[RMQMultipleChannelAllocator alloc]
                                                initWithMaxCapacity:[channelMax unsignedIntegerValue]
                                                channelSyncTimeout:syncTimeout];
    RMQQueuingConnectionDelegateProxy *delegateProxy = [[RMQQueuingConnectionDelegateProxy alloc]
                                                            initWithDelegate:delegate
                                                            queue:delegateQueue];
    RMQSemaphoreWaiterFactory *waiterFactory = [RMQSemaphoreWaiterFactory new];
    RMQGCDHeartbeatSender *heartbeatSender = [[RMQGCDHeartbeatSender alloc] initWithTransport:transport
                                                                                        clock:[RMQTickingClock new]];
    RMQCredentials *credentials = [[RMQCredentials alloc] initWithUsername:rmqURI.username
                                                                  password:rmqURI.password];


    RMQProcessInfoNameGenerator *nameGenerator = [RMQProcessInfoNameGenerator new];
    RMQGCDSerialQueue *commandQueue = [[RMQGCDSerialQueue alloc]
                                        initWithName:[nameGenerator generateWithPrefix:@"connection-commands"]];
    RMQConnectionRecover *recovery = [[RMQConnectionRecover alloc] initWithInterval:recoveryInterval
                                                                       attemptLimit:recoveryAttempts
                                                                         onlyErrors:!shouldRecoverFromConnectionClose
                                                                    heartbeatSender:heartbeatSender
                                                                       commandQueue:commandQueue
                                                                           delegate:delegateProxy];

    RMQConnectionConfig *config = [[RMQConnectionConfig alloc] initWithCredentials:credentials
                                                                        channelMax:channelMax
                                                                          frameMax:frameMax
                                                                         heartbeat:heartbeat
                                                                             vhost:rmqURI.vhost
                                                                     authMechanism:tlsOptions.authMechanism
                                                                          recovery:recovery];
    return [self initWithTransport:transport
                            config:config
                  handshakeTimeout:syncTimeout
                  channelAllocator:allocator
                      frameHandler:allocator
                          delegate:delegateProxy
                      commandQueue:commandQueue
                     waiterFactory:waiterFactory
                   heartbeatSender:heartbeatSender];
}

- (instancetype)initWithUri:(NSString *)uri
                   delegate:(id<RMQConnectionDelegate>)delegate
               recoverAfter:(NSNumber *)recoveryInterval {
    return [self initWithUri:uri
                  tlsOptions:[RMQTLSOptions fromURI:uri]
                  channelMax:@(RMQChannelMaxDefault)
                    frameMax:@(RMQFrameMax)
                   heartbeat:RMQDefaultHeartbeatTimeout
              connectTimeout:RMQDefaultConnectTimeout
                 readTimeout:RMQDefaultReadTimeout
                writeTimeout:RMQDefaultWriteTimeout
                 syncTimeout:RMQDefaultSyncTimeout
                    delegate:delegate
               delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                recoverAfter:recoveryInterval
            recoveryAttempts:@(NSUIntegerMax)
  recoverFromConnectionClose:YES];
}

- (instancetype)initWithUri:(NSString *)uri
                   delegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:uri
                  tlsOptions:[RMQTLSOptions fromURI:uri]
                  channelMax:@(RMQChannelMaxDefault)
                    frameMax:@(RMQFrameMax)
                   heartbeat:RMQDefaultHeartbeatTimeout
              connectTimeout:RMQDefaultConnectTimeout
                 readTimeout:RMQDefaultReadTimeout
                writeTimeout:RMQDefaultWriteTimeout
                 syncTimeout:RMQDefaultSyncTimeout
                    delegate:delegate
               delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                recoverAfter:RMQDefaultRecoveryInterval
            recoveryAttempts:@(NSUIntegerMax)
  recoverFromConnectionClose:YES];
}

- (instancetype)initWithUri:(NSString *)uri
             connectTimeout:(nonnull NSNumber*)connectTimeout
                readTimeout:(nonnull NSNumber*)readTimeout
               writeTimeout:(nonnull NSNumber*)writeTimeout
                   delegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:uri
                  tlsOptions:[RMQTLSOptions fromURI:uri]
                  channelMax:@(RMQChannelMaxDefault)
                    frameMax:@(RMQFrameMax)
                   heartbeat:RMQDefaultHeartbeatTimeout
              connectTimeout:connectTimeout
                 readTimeout:readTimeout
                writeTimeout:writeTimeout
                 syncTimeout:RMQDefaultSyncTimeout
                    delegate:delegate
               delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                recoverAfter:RMQDefaultRecoveryInterval
            recoveryAttempts:@(NSUIntegerMax)
  recoverFromConnectionClose:YES];
}

- (instancetype)initWithUri:(NSString *)uri
                 tlsOptions:(RMQTLSOptions *)tlsOptions
                 channelMax:(NSNumber *)channelMax
                   frameMax:(NSNumber *)frameMax
                  heartbeat:(NSNumber *)heartbeat
             connectTimeout:(nonnull NSNumber*)connectTimeout
                readTimeout:(nonnull NSNumber*)readTimeout
               writeTimeout:(nonnull NSNumber*)writeTimeout
                syncTimeout:(NSNumber *)syncTimeout
                   delegate:(id<RMQConnectionDelegate>)delegate
              delegateQueue:(dispatch_queue_t)delegateQueue {
    return [self initWithUri:uri
                  tlsOptions:tlsOptions
                  channelMax:channelMax
                    frameMax:frameMax
                   heartbeat:heartbeat
              connectTimeout:connectTimeout
                 readTimeout:readTimeout
                writeTimeout:writeTimeout
                 syncTimeout:syncTimeout
                    delegate:delegate
               delegateQueue:delegateQueue
                recoverAfter:RMQDefaultRecoveryInterval
            recoveryAttempts:@(NSUIntegerMax)
  recoverFromConnectionClose:YES];
}

- (instancetype)initWithUri:(NSString *)uri
                 channelMax:(NSNumber *)channelMax
                   frameMax:(NSNumber *)frameMax
                  heartbeat:(NSNumber *)heartbeat
             connectTimeout:(nonnull NSNumber*)connectTimeout
                readTimeout:(nonnull NSNumber*)readTimeout
               writeTimeout:(nonnull NSNumber*)writeTimeout
                syncTimeout:(NSNumber *)syncTimeout
                   delegate:(id<RMQConnectionDelegate>)delegate
              delegateQueue:(dispatch_queue_t)delegateQueue {
    return [self initWithUri:uri
                  tlsOptions:[RMQTLSOptions fromURI:uri]
                  channelMax:channelMax
                    frameMax:frameMax
                   heartbeat:heartbeat
              connectTimeout:connectTimeout
                 readTimeout:readTimeout
                writeTimeout:writeTimeout
                 syncTimeout:syncTimeout
                    delegate:delegate
               delegateQueue:delegateQueue];
}

- (instancetype)initWithUri:(NSString *)uri
                 tlsOptions:(RMQTLSOptions *)tlsOptions
                   delegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:uri
                  tlsOptions:tlsOptions
                  channelMax:@(RMQChannelMaxDefault)
                    frameMax:@(RMQFrameMax)
                   heartbeat:RMQDefaultHeartbeatTimeout
              connectTimeout:RMQDefaultConnectTimeout
                 readTimeout:RMQDefaultReadTimeout
                writeTimeout:RMQDefaultWriteTimeout
                 syncTimeout:RMQDefaultSyncTimeout
                    delegate:delegate
               delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (instancetype)initWithUri:(NSString *)uri
                 verifyPeer:(BOOL)verifyPeer
                   delegate:(id<RMQConnectionDelegate>)delegate {
    RMQTLSOptions *tlsOptions = [RMQTLSOptions fromURI:uri verifyPeer:verifyPeer];
    return [self initWithUri:uri tlsOptions:tlsOptions delegate:delegate];
}

- (instancetype)initWithDelegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:@"amqp://guest:guest@localhost" delegate:delegate];
}

- (instancetype)init
{
    return [self initWithDelegate:nil];
}

- (void)start:(void (^)(void))completionHandler {
    NSError *connectError = NULL;

    [self.transport connectAndReturnError:&connectError];
    if (connectError) {
        [self.delegate connection:self failedToConnectWithError:connectError];
    } else {
        [self.transport write:[RMQProtocolHeader new].amqEncoded];

        [self.commandQueue enqueue:^{
            id<RMQWaiter> handshakeCompletion = [self.waiterFactory makeWithTimeout:self.handshakeTimeout];

            RMQHandshaker *handshaker = [[RMQHandshaker alloc] initWithSender:self
                                                                       config:self.config
                                                            completionHandler:^(NSNumber *heartbeatTimeout,
                                                                                RMQTable *serverProperties) {
                                                                [self.heartbeatSender startWithInterval:@(heartbeatTimeout.integerValue / 2)];
                                                                self.handshakeComplete = YES;
                                                                [handshakeCompletion done];
                                                                [self.reader run];
                                                                self.serverProperties = serverProperties;
                                                                completionHandler();
                                                            }];
            RMQReader *handshakeReader = [[RMQReader alloc] initWithTransport:self.transport
                                                                 frameHandler:handshaker];
            handshaker.reader = handshakeReader;
            [handshakeReader run];

            if (handshakeCompletion.timesOut) {
                NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                                     code:RMQErrorConnectionHandshakeTimedOut
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Handshake timed out."}];
                [self.delegate connection:self failedToConnectWithError:error];
            }
        }];
    }
}

- (void)start {
    [self start:^{}];
}

- (id<RMQChannel>)createChannel {
    id<RMQChannel> ch = self.channelAllocator.allocate;
    self.userChannels[ch.channelNumber] = ch;

    [self.commandQueue enqueue:^{
        [ch activateWithDelegate:self.delegate];
    }];

    [ch open];

    return ch;
}

- (BOOL)isOpen {
    return self.transport.isConnected;
}

- (BOOL)isClosed {
    return !self.isOpen;
}

- (void)close {
    [self reportErrorIfAlreadyClosed];
    for (RMQOperation operation in self.safeCloseOperations) {
        [self.commandQueue enqueue:operation];
    }
}

- (void)blockingClose {
    [self reportErrorIfAlreadyClosed];
    // this enqueues a blocking command,
    // so be idempotent
    if(self.isOpen) {
        for (RMQOperation operation in self.safeCloseOperations) {
            [self.commandQueue blockingEnqueue:operation];
        }
    }
}

/**
 If called when connection is closed (or never was successfully completed),
 will report an error to the delegate.
 */
- (void)reportErrorIfAlreadyClosed {
    if (!self.handshakeComplete) {
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQErrorConnectionHandshakeTimedOut
                                         userInfo:@{NSLocalizedDescriptionKey: @"attempt to close an already closed (or never successfully established) connection"}];
        [self.delegate connection:self failedToConnectWithError:error];
    }
}

# pragma mark - RMQSender

- (void)sendFrameset:(RMQFrameset *)frameset
               force:(BOOL)isForced {
    if (self.handshakeComplete || isForced) {
        [self.transport write:frameset.amqEncoded];
        [self.heartbeatSender signalActivity];
    }
}

- (void)sendFrameset:(RMQFrameset *)frameset {
    [self sendFrameset:frameset force:NO];
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(RMQFrameset *)frameset {
    id method = frameset.method;

    if ([method isKindOfClass:[RMQConnectionClose class]]) {
        [self sendFrameset:[[RMQFrameset alloc] initWithChannelNumber:@0 method:[RMQConnectionCloseOk new]]];
        self.handshakeComplete = NO;
        [self.transport close];
        self.transport.delegate = self;
    } else {
        [self.frameHandler handleFrameset:frameset];
        [self.reader run];
    }
}

# pragma mark - RMQTransportDelegate

- (void)transport:(id<RMQTransport>)transport disconnectedWithError:(NSError *)error {
    self.handshakeComplete = NO;
    if (error) [self.delegate connection:self disconnectedWithError:error];
    [self.recovery recover:self
          channelAllocator:self.channelAllocator
                     error:error];
}

# pragma mark - Private

- (NSArray *)safeCloseOperations {
    return self.handshakeComplete ? [self closeOperations] : [self closeOperationsWithoutBlock];
}

/**
 Used to safely close a connection (including connections that were never successfully opened)
 */
- (NSArray *)closeOperationsWithoutBlock {
    return @[^{[self closeAllUserChannels];},
              ^{[self sendFrameset:[[RMQFrameset alloc] initWithChannelNumber:@0 method:self.amqClose]];},
              ^{[self.heartbeatSender stop];},
              ^{
                  self.transport.delegate = nil;
                  [self.transport close];
              }];
}


- (NSArray *)closeOperations {
    return @[^{[self closeAllUserChannels];},
              ^{[self sendFrameset:[[RMQFrameset alloc] initWithChannelNumber:@0 method:self.amqClose]];},
              ^{[self.channelZero blockingWaitOn:[RMQConnectionCloseOk class]];},
              ^{[self.heartbeatSender stop];},
              ^{
                  self.transport.delegate = nil;
                  [self.transport close];
              }];
}

- (void)closeAllUserChannels {
    for (id<RMQChannel> ch in self.userChannels.allValues) {
        [ch blockingClose];
    }
}

- (RMQConnectionClose *)amqClose {
    return [[RMQConnectionClose alloc] initWithReplyCode:[[RMQShort alloc] init:200]
                                               replyText:[[RMQShortstr alloc] init:@"Goodbye"]
                                                 classId:[[RMQShort alloc] init:0]
                                                methodId:[[RMQShort alloc] init:0]];
}

- (id<RMQConnectionRecovery>)recovery {
    return self.config.recovery;
}

@end
