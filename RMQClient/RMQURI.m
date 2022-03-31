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

/*! @brief Parses virtual host out from the path component.
 *  @discussion Slashes in URI path must be percent-encoded as "%2F" or "%2f".
 *
 *              This method assumes that the default virtual host used by clients
 *              is a single slash ("/"). It will be returned in cases where the path
 *              component only consists of a URI component separator (a slash),
 *              for example, "amqp://hostname:5672/".
 *              If the path component is blank but the separator is present, an empty
 *              string will be returned.
 *              See https://www.rabbitmq.com/uri-spec.html for details.
 */
+ (NSString *)parseVhost:(NSURLComponents *)components error:(NSError **)error {
    NSString *path = components.path;
    // Missing path means missing virtual host,
    // so return the default
    if (path.length == 0) {
        return @"/";
    }

    // will include a trailing slash
    NSString *vhost = [path substringFromIndex:1];

    // if the vhost is blank we return it as is and
    // not the defaut, per https://www.rabbitmq.com/uri-spec.html
    return [vhost stringByRemovingPercentEncoding];
}
@end
