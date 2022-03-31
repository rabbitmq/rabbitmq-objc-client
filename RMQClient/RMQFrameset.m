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

#import "RMQFrameset.h"
#import "RMQFrame.h"

@interface RMQFrameset ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQMethod> method;
@property (nonatomic, readwrite) RMQContentHeader *contentHeader;
@property (nonatomic, readwrite) NSArray *contentBodies;
@end

@implementation RMQFrameset

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                               method:(id<RMQMethod>)method
                        contentHeader:(RMQContentHeader *)contentHeader
                        contentBodies:(NSArray *)contentBodies {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.method = method;
        self.contentHeader = contentHeader;
        self.contentBodies = contentBodies;
    }
    return self;
}

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                               method:(id<RMQMethod>)method {
    return [self initWithChannelNumber:channelNumber
                                method:method
                         contentHeader:[RMQContentHeaderNone new]
                         contentBodies:@[]];
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.method].amqEncoded];
    NSData *contentHeaderEncoded = self.contentHeader.amqEncoded;
    if (contentHeaderEncoded.length) {
        [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.contentHeader].amqEncoded];
        for (RMQContentBody *body in self.contentBodies) {
            [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:body].amqEncoded];
        }
    }
    return encoded;
}

- (NSData *)contentData {
    NSMutableData *allBodyData = [NSMutableData new];
    for (RMQContentBody *b in self.contentBodies) {
        [allBodyData appendData:b.data];
    }
    return allBodyData;
}

- (RMQFrameset *)addBody:(RMQContentBody *)body {
    NSArray *conjoinedContentBodies = [self.contentBodies arrayByAddingObject:body];

    return [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                               method:self.method
                                        contentHeader:self.contentHeader
                                        contentBodies:conjoinedContentBodies];
}

@end
