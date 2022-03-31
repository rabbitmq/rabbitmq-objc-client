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

#import "RMQHandshaker.h"

@interface RMQHandshaker ()
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQConnectionConfig *config;
@property (nonatomic, readwrite) void (^completionHandler)(NSNumber *heartbeatTimeout,
                                                           RMQTable *serverProperties);
@property (nonatomic, readwrite) NSNumber *heartbeatTimeout;
@property (nonatomic, readwrite) RMQTable *serverProperties;
@end

@implementation RMQHandshaker

- (instancetype)initWithSender:(id<RMQSender>)sender
                        config:(RMQConnectionConfig *)config
             completionHandler:(void (^)(NSNumber *heartbeatTimeout,
                                         RMQTable *serverProperties))completionHandler {
    self = [super init];
    if (self) {
        self.sender = sender;
        self.config = config;
        self.completionHandler = completionHandler;
        self.heartbeatTimeout = @0;
    }
    return self;
}

- (void)handleFrameset:(RMQFrameset *)frameset {
    id method = frameset.method;
    if ([method isKindOfClass:[RMQConnectionStart class]]) {
        RMQConnectionStart *start = method;
        self.serverProperties = start.serverProperties;
        [self sendMethod:self.startOk channelNumber:frameset.channelNumber];
        [self.reader run];
    } else if ([method isKindOfClass:[RMQConnectionTune class]]) {
        RMQConnectionTuneOk *tuneOk = [self tuneOkForTune:method];
        self.heartbeatTimeout = @(tuneOk.heartbeat.integerValue);

        [self sendMethod:tuneOk channelNumber:frameset.channelNumber];
        [self sendMethod:self.connectionOpen channelNumber:frameset.channelNumber];
        [self.reader run];
    } else {
        self.completionHandler(self.heartbeatTimeout,
                               self.serverProperties);
    }
}

#pragma mark - Private

- (RMQConnectionStartOk *)startOk {
    RMQBoolean *yes = [[RMQBoolean alloc] init:YES];
    RMQTable *capabilities = [[RMQTable alloc] init:@{@"publisher_confirms"           : yes,
                                                      @"consumer_cancel_notify"       : yes,
                                                      @"exchange_exchange_bindings"   : yes,
                                                      @"basic.nack"                   : yes,
                                                      @"connection.blocked"           : yes,
                                                      @"authentication_failure_close" : yes}];

    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"io.pivotal.RMQClient"];
    NSString *version = bundle.infoDictionary[@"CFBundleShortVersionString"];

    NSDictionary *libraryProperties = @{@"capabilities" : capabilities,
                                        @"product"      : [[RMQLongstr alloc] init:@"RMQClient"],
                                        @"platform"     : [[RMQLongstr alloc] init:@"iOS"],
                                        @"version"      : [[RMQLongstr alloc] init:version],
                                        @"information"  : [[RMQLongstr alloc] init:@"https://github.com/rabbitmq/rabbitmq-objc-client"]};
    NSMutableDictionary *combinedProperties = [[NSMutableDictionary alloc] initWithDictionary:libraryProperties];

    NSString *userProvidedConnectionName = [self.config userProvidedConnectionName];
    if (userProvidedConnectionName != nil) {
        [combinedProperties setObject:[[RMQLongstr alloc] init:userProvidedConnectionName]
                               forKey:@"connection_name"];
    }
    RMQTable *clientProperties = [[RMQTable alloc] init:combinedProperties];

    return [[RMQConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                        mechanism:[[RMQShortstr alloc] init:self.config.authMechanism]
                                                         response:self.config.credentials
                                                           locale:[[RMQShortstr alloc] init:@"en_GB"]];
}

- (RMQConnectionTuneOk *)tuneOkForTune:(RMQConnectionTune *)tune {
    RMQConnectionConfig *client = self.config;
    RMQConnectionTune *server = tune;

    NSNumber *channelMax = [self negotiateBetweenClientValue:client.channelMax
                                                 serverValue:@(server.channelMax.integerValue)];
    NSNumber *frameMax   = [self negotiateBetweenClientValue:client.frameMax
                                                 serverValue:@(server.frameMax.integerValue)];
    NSNumber *heartbeat  = [self negotiateBetweenClientValue:client.heartbeat
                                                 serverValue:@(server.heartbeat.integerValue)];
    return [[RMQConnectionTuneOk alloc] initWithChannelMax:[[RMQShort alloc] init:channelMax.integerValue]
                                                  frameMax:[[RMQLong alloc] init:frameMax.integerValue]
                                                 heartbeat:[[RMQShort alloc] init:heartbeat.integerValue]];
}

- (RMQConnectionOpen *)connectionOpen {
    return [[RMQConnectionOpen alloc] initWithVirtualHost:[[RMQShortstr alloc] init:self.config.vhost]
                                                reserved1:[[RMQShortstr alloc] init:@""]
                                                  options:0];
}

- (NSNumber *)negotiateBetweenClientValue:(NSNumber *)client
                              serverValue:(NSNumber *)server {
    if ([client isEqualToNumber:@0] || [server isEqualToNumber:@0]) {
        return client.integerValue > server.integerValue ? client : server;
    } else {
        return client.integerValue < server.integerValue ? client : server;
    }
}

- (void)sendMethod:(id<RMQMethod>)amqMethod channelNumber:(NSNumber *)channelNumber {
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:channelNumber method:amqMethod];
    [self.sender sendFrameset:frameset force:YES];
}
@end
