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

#import "RMQURI.h"
#import "RMQErrors.h"

@interface RMQURI ()
@property (nonatomic,nonnull,readwrite) NSString *host;
@property (nonatomic,nonnull,readwrite) NSString *vhost;
@property (nonatomic,nonnull,readwrite) NSNumber *portNumber;
@property (nonatomic,nonnull,readwrite) NSString *username;
@property (nonatomic,nonnull,readwrite) NSString *password;
@property (nonatomic,readwrite) BOOL isTLS;
@end

@implementation RMQURI
+ (instancetype)parse:(NSString *)uri error:(NSError *__autoreleasing  _Nullable *)error {
    NSURLComponents *components = [NSURLComponents componentsWithString:uri];
    
    if (![self isValidScheme:components.scheme]) {
        *error = [NSError errorWithDomain:RMQErrorDomain
                                     code:RMQErrorInvalidScheme
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK", nil)}];
        return nil;
    }

    NSError *parseVhostError = NULL;
    NSString *vhost = [self parseVhost:components error:&parseVhostError];
    if (parseVhostError) {
        *error = parseVhostError;
        return nil;
    }
    
    RMQURI *u = [[RMQURI alloc] init];
    u.host = components.host;
    u.vhost = vhost;
    u.username = components.user;
    u.password = components.password;
    u.portNumber = components.port;

    if ([components.scheme isEqualToString:@"amqp"]) {
        u.portNumber = u.portNumber ?: @5672;
        u.isTLS = NO;
    } else if ([components.scheme isEqualToString:@"amqps"]) {
        u.portNumber = u.portNumber ?: @5671;
        u.isTLS = YES;
    }
    
    return u;
}

+ (BOOL)isValidScheme:(NSString *)scheme {
    return [scheme isEqualToString:@"amqp"] || [scheme isEqualToString:@"amqps"];
}

+ (NSString *)parseVhost:(NSURLComponents *)components error:(NSError **)error {
    NSRegularExpression *r = [NSRegularExpression
                              regularExpressionWithPattern:@"/"
                              options:NSRegularExpressionCaseInsensitive
                              error:NULL];
    NSUInteger numberOfSlashes = [r numberOfMatchesInString:components.path options:0 range:NSMakeRange(0, components.path.length)];
    
    if (numberOfSlashes > 2) {
        NSString *msg = [NSString stringWithFormat:@"%@ has multiple-segment path; please percent-encode any slashes in the vhost name (e.g. /production => %%2Fproduction). Learn more at http://bit.ly/amqp-gem-and-connection-uris", components.URL];
        *error = [NSError errorWithDomain:RMQErrorDomain code:RMQErrorInvalidPath userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)}];
        return nil;
    } else if (components.path.length == 0) {
        return @"/";
    } else {
        return [components.path substringFromIndex:1];
    }
}
@end
