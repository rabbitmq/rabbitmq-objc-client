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

#import "RMQPKCS12CertificateConverter.h"
#import "RMQErrors.h"

@interface RMQPKCS12CertificateConverter ()
@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) NSString *password;
@end

@implementation RMQPKCS12CertificateConverter

- (instancetype)initWithData:(NSData *)data
                    password:(NSString *)password {
    self = [super init];
    if (self) {
        self.data = data;
        self.password = password;
    }
    return self;
}

- (NSArray *)certificatesWithError:(NSError *__autoreleasing *)error {
    if (self.data.length == 0) return @[];

    SecIdentityRef identity;
    [self parseIdentity:self.data identity:&identity error:error];

    if (*error) {
        return nil;
    } else {
        return @[(__bridge id)identity];
    }
}

# pragma mark - Private

- (void)parseIdentity:(NSData *)data identity:(SecIdentityRef *)identity error:(NSError **)error {
    CFDataRef cfData = (__bridge CFDataRef)data;
    NSDictionary *options = @{(__bridge NSString *)kSecImportExportPassphrase: self.password};
    CFArrayRef items = NULL;
    OSStatus status = SecPKCS12Import(cfData, (__bridge CFDictionaryRef)options, &items);

    switch (status) {
        case errSecSuccess:
            *identity = (SecIdentityRef)CFDictionaryGetValue(CFArrayGetValueAtIndex(items, 0),
                                                             kSecImportItemIdentity);
            break;

        case errSecAuthFailed:
            *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:RMQErrorTLSCertificateAuthFailure
                                     userInfo:@{NSLocalizedDescriptionKey: @"TLS certificate authentication failed. Incorrect password?"}];
            break;

        case errSecDecode:
            *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:RMQErrorTLSCertificateDecodeError
                                     userInfo:@{NSLocalizedDescriptionKey: @"TLS certificate decoding error. Corrupt PKCS12 data?"}];
            break;

        default:
            break;
    }
}

@end
