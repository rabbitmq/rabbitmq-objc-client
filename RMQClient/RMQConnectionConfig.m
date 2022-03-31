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

#import "RMQFrame.h"
#import "RMQConnectionConfig.h"

/**
 * @brief Default channel max value. One channel per connection
 *        is reserved for protocol negotiation, error reporting
 *        and so on.
 */
NSInteger const RMQChannelMaxDefault = 127;

@interface RMQConnectionConfig ()
@property (nonnull, nonatomic, readwrite) NSNumber *channelMax;
@property (nonnull, nonatomic, readwrite) NSNumber *frameMax;
@property (nonnull, nonatomic, readwrite) NSNumber *heartbeat;
@property (nonnull, nonatomic, readwrite) NSString *vhost;
@property (nonnull, nonatomic, readwrite) RMQCredentials *credentials;
@property (nonnull, nonatomic, readwrite) NSString *authMechanism;
@property (nonatomic, readwrite) NSString *userProvidedConnectionName;
@property (nonnull, nonatomic, readwrite) id<RMQConnectionRecovery> recovery;
@end

@implementation RMQConnectionConfig
- (instancetype)initWithCredentials:(RMQCredentials *)credentials
                         channelMax:(NSNumber *)channelMax
                           frameMax:(NSNumber *)frameMax
                          heartbeat:(NSNumber *)heartbeat
                              vhost:(nonnull NSString *)vhost
                      authMechanism:(nonnull NSString *)authMechanism
                           recovery:(nonnull id<RMQConnectionRecovery>)recovery {
    self = [super init];
    if (self) {
        self.credentials = credentials;
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.vhost = vhost;
        self.authMechanism = authMechanism;
        self.recovery = recovery;
    }
    return self;
}

- (instancetype)initWithCredentials:(RMQCredentials *)credentials
                          heartbeat:(NSNumber *)heartbeat
                              vhost:(nonnull NSString *)vhost
                      authMechanism:(nonnull NSString *)authMechanism
                           recovery:(nonnull id<RMQConnectionRecovery>)recovery {
    return [self initWithCredentials:credentials
                          channelMax:[NSNumber numberWithInteger:RMQChannelMaxDefault]
                            frameMax:[NSNumber numberWithInteger:RMQFrameMax]
                           heartbeat:heartbeat
                               vhost:vhost
                       authMechanism:authMechanism
                            recovery:recovery];
}

- (instancetype)initWithCredentials:(RMQCredentials *)credentials
                         channelMax:(NSNumber *)channelMax
                           frameMax:(NSNumber *)frameMax
                          heartbeat:(NSNumber *)heartbeat
                              vhost:(nonnull NSString *)vhost
                      authMechanism:(nonnull NSString *)authMechanism
         userProvidedConnectionName:(nonnull NSString *)userProvidedConnectionName
                           recovery:(nonnull id<RMQConnectionRecovery>)recovery {
    self = [super init];
    if (self) {
        self.credentials = credentials;
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.vhost = vhost;
        self.authMechanism = authMechanism;
        self.userProvidedConnectionName = userProvidedConnectionName;
        self.recovery = recovery;
    }
    return self;
}

- (instancetype)initWithCredentials:(RMQCredentials *)credentials
                          heartbeat:(NSNumber *)heartbeat
                              vhost:(nonnull NSString *)vhost
                      authMechanism:(nonnull NSString *)authMechanism
         userProvidedConnectionName:(nonnull NSString *)userProvidedConnectionName
                           recovery:(nonnull id<RMQConnectionRecovery>)recovery {
    return [self initWithCredentials:credentials
                          channelMax:[NSNumber numberWithInteger:RMQChannelMaxDefault]
                            frameMax:[NSNumber numberWithInteger:RMQFrameMax]
                           heartbeat:heartbeat
                               vhost:vhost
                       authMechanism:authMechanism
          userProvidedConnectionName:userProvidedConnectionName
                            recovery:recovery];
}
@end
