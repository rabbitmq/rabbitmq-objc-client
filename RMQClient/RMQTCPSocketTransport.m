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

#import "RMQTCPSocketTransport.h"
#import "RMQErrors.h"
#import "RMQSynchronizedMutableDictionary.h"
#import "RMQPKCS12CertificateConverter.h"
#import "RMQTCPSocketConfigurator.h"

long writeTag = UINT32_MAX + 1;
RMQTCPSocketConfigurator noOpSocketConfigurator = ^(GCDAsyncSocket* _socket) {};

@interface RMQTCPSocketTransport ()

@property (nonatomic, readwrite) NSString *host;
@property (nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) RMQTLSOptions *tlsOptions;
@property (atomic, readwrite) BOOL _isConnected;
@property (nonatomic, readwrite) GCDAsyncSocket *socket;
@property (nonatomic, readwrite) id callbacks;
@property (nonatomic, readwrite) NSTimeInterval connectTimeout;
@property (nonatomic, readwrite) NSTimeInterval readTimeout;
@property (nonatomic, readwrite) NSTimeInterval writeTimeout;
@property (nonatomic, readwrite) NSData *pkcs12data;

@end

@implementation RMQTCPSocketTransport
@synthesize delegate;

- (instancetype)initWithHost:(NSString *)host
                        port:(NSNumber *)port

                  tlsOptions:(RMQTLSOptions *)tlsOptions
             callbackStorage:(id)callbacks
          socketConfigurator:(RMQTCPSocketConfigurator)socketConfigurator
              connectTimeout:(nonnull NSNumber *)connectTimeout
                 readTimeout:(nonnull NSNumber *)readTimeout
                writeTimeout:(nonnull NSNumber *)writeTimeout;{
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        // see rabbitmq/rabbitmq-objc-client#138
        self.socket.IPv4PreferredOverIPv6 = NO;
        self.host = host;
        self.port = port;
        self.tlsOptions = tlsOptions;
        self.callbacks = callbacks;

        self.connectTimeout = [connectTimeout doubleValue];
        self.readTimeout = [readTimeout doubleValue];
        self.writeTimeout = [writeTimeout doubleValue];
        
        socketConfigurator(self.socket);
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host
                        port:(NSNumber *)port
                  tlsOptions:(RMQTLSOptions *)tlsOptions
          socketConfigurator:(RMQTCPSocketConfigurator)socketConfigurator
              connectTimeout:(nonnull NSNumber *)connectTimeout
                 readTimeout:(nonnull NSNumber *)readTimeout
                writeTimeout:(nonnull NSNumber *)writeTimeout {
    return [self initWithHost:host
                        port:port
                  tlsOptions:tlsOptions
             callbackStorage:[RMQSynchronizedMutableDictionary new]
          socketConfigurator:socketConfigurator
               connectTimeout:connectTimeout
                  readTimeout:readTimeout
                 writeTimeout:writeTimeout];
}

- (instancetype)initWithHost:(NSString *)host
                        port:(NSNumber *)port
                  tlsOptions:(RMQTLSOptions *)tlsOptions
              connectTimeout:(nonnull NSNumber *)connectTimeout
                 readTimeout:(nonnull NSNumber *)readTimeout
                writeTimeout:(nonnull NSNumber *)writeTimeout{
    return [self initWithHost:host
                         port:port
                   tlsOptions:tlsOptions
              callbackStorage:[RMQSynchronizedMutableDictionary new]
           socketConfigurator:noOpSocketConfigurator
               connectTimeout:connectTimeout
                  readTimeout:readTimeout
                 writeTimeout:writeTimeout];
}


- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)connectAndReturnError:(NSError *__autoreleasing  _Nullable *)error {
    BOOL success = [self.socket connectToHost:self.host
                                       onPort:self.port.unsignedIntegerValue
                                        error:error];
    if (self.tlsOptions.useTLS) {
        return [self tlsUpgradeWithError:error];
    } else {
        return success;
    }
}

- (void)close {
    [self.socket disconnect];
    self._isConnected = NO;
}

- (void)write:(NSData *)data {
    [self.socket writeData:data
               withTimeout:self.writeTimeout
                       tag:writeTag];
}

struct __attribute__((__packed__)) AMQPHeader {
    UInt8  type;
    UInt16 channel;
    UInt32 size;
};

#define AMQP091_HEADER_SIZE 7
#define AMQP091_FINAL_OCTET_SIZE 1

- (void)readFrame:(void (^)(NSData * _Nonnull))complete {
    __weak id this = self;
    [self read:AMQP091_HEADER_SIZE complete:^(NSData * _Nonnull data) {
        const struct AMQPHeader *header;
        header = (const struct AMQPHeader *)data.bytes;
        __strong typeof(self) strongThis = this;
        UInt32 hostSize = CFSwapInt32BigToHost(header->size);
        
        [strongThis read:hostSize complete:^(NSData * _Nonnull payload) {
            [strongThis read:AMQP091_FINAL_OCTET_SIZE complete:^(NSData * _Nonnull frameEnd) {
                NSMutableData *allData = [data mutableCopy];
                [allData appendData:payload];
                complete(allData);
            }];
        }];
    }];
}

- (void)simulateDisconnect {
    id<GCDAsyncSocketDelegate> oldDelegate = self.socket.delegate;
    self.socket.delegate = nil;
    [self.socket disconnect];
    NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:RMQErrorSimulatedDisconnect
                                     userInfo:@{NSLocalizedDescriptionKey: @"Simulated disconnect"}];
    [self socketDidDisconnect:self.socket withError:error];
    self.socket.delegate = oldDelegate;
}

- (BOOL)isConnected {
    return self._isConnected;
}

- (BOOL)isDisconnected {
    return !self._isConnected;
}

# pragma mark - Private

- (void)read:(NSUInteger)len complete:(void (^)(NSData * _Nonnull))complete {
    if (len == 0) {
        complete([NSData data]);
    } else {
        [self.socket readDataToLength:len
                          withTimeout:10
                                  tag:[self storeCallback:complete]];
    }
}

- (long)storeCallback:(id)callback {
    uint32_t tag = arc4random_uniform(INT32_MAX);
    self.callbacks[@(tag)] = [callback copy];
    return tag;
}

- (void)invokeZeroArityCallback:(long)tag {
    void (^foundCallback)(void) = self.callbacks[@(tag)];
    [self.callbacks removeObjectForKey:@(tag)];
    if (foundCallback) {
        foundCallback();
    }
}
- (void)cleanup {
    [self.callbacks removeAllObjects];
}

- (BOOL)tlsUpgradeWithError:(NSError **)error {
    NSArray *certificates = [self.tlsOptions certificatesWithError:error];
    if (*error) return NO;
    NSMutableDictionary *opts = [@{GCDAsyncSocketManuallyEvaluateTrust: @(!self.tlsOptions.verifyPeer),
                                   GCDAsyncSocketSSLPeerName: self.tlsOptions.peerName} mutableCopy];
    if (certificates.count > 0) opts[GCDAsyncSocketSSLCertificates] = certificates;
    [self.socket startTLS:opts];
    return YES;
}

- (dispatch_time_t)connectTimeoutFromNow {
    return dispatch_time(DISPATCH_TIME_NOW, self.connectTimeout * NSEC_PER_SEC);
}

# pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    void (^foundCallback)(NSData *) = self.callbacks[@(tag)];
    [self.callbacks removeObjectForKey:@(tag)];
    foundCallback(data);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    return 10000;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
    [self.delegate transport:self disconnectedWithError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self invokeZeroArityCallback:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler(YES);
}

@end
