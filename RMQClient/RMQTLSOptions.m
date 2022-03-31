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

#import "RMQTLSOptions.h"
#import "RMQTCPSocketTransport.h"
#import "RMQPKCS12CertificateConverter.h"
#import "RMQURI.h"

@interface RMQTLSOptions ()

@property (nonatomic, readwrite) BOOL useTLS;
@property (nonatomic, readwrite) BOOL verifyPeer;
@property (nonnull, nonatomic, readwrite) NSString *peerName;
@property (nullable, nonatomic, readwrite) NSData *pkcs12data;
@property (nullable, nonatomic, readwrite) NSString *pkcs12password;

@end

@implementation RMQTLSOptions

+ (instancetype)fromURI:(NSString *)s verifyPeer:(BOOL)verifyPeer {
    NSError *error = NULL;
    RMQURI *uri = [RMQURI parse:s error:&error];
    return [[RMQTLSOptions alloc] initWithUseTLS:uri.isTLS
                                        peerName:uri.host
                                      verifyPeer:verifyPeer
                                          pkcs12:nil
                                  pkcs12Password:nil];
}

+ (instancetype)fromURI:(NSString *)uri {
    return [RMQTLSOptions fromURI:uri verifyPeer:YES];
}

- (instancetype)initWithPeerName:(NSString *)peerName
                      verifyPeer:(BOOL)verifyPeer
                          pkcs12:(NSData *)pkcs12data
                  pkcs12Password:(NSString *)password {
    return [self initWithUseTLS:YES
                       peerName:peerName
                     verifyPeer:verifyPeer
                         pkcs12:pkcs12data
                 pkcs12Password:password];
}

- (NSString *)authMechanism {
    return self.pkcs12data ? @"EXTERNAL" : @"PLAIN";
}

- (NSArray *)certificatesWithError:(NSError **)error {
    RMQPKCS12CertificateConverter *converter = [[RMQPKCS12CertificateConverter alloc] initWithData:self.pkcs12data
                                                                                          password:self.pkcs12password];
    return [converter certificatesWithError:error];
}

# pragma mark - Private

- (instancetype)initWithUseTLS:(BOOL)useTLS
                      peerName:(NSString *)peerName
                    verifyPeer:(BOOL)verifyPeer
                        pkcs12:(NSData *)pkcs12data
                pkcs12Password:(NSString *)password {
    self = [super init];
    if (self) {
        self.useTLS = useTLS;
        self.peerName = peerName;
        self.verifyPeer = verifyPeer;
        self.pkcs12data = pkcs12data;
        self.pkcs12password = password;
    }
    return self;
}

@end
