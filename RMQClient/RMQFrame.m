// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 2.0 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright (c) 2007-2024 Broadcom. All Rights Reserved. The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries. All rights reserved.
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
#import "RMQMethodDecoder.h"
#import "RMQHeartbeat.h"

NSUInteger const RMQFrameMax = 131072;
NSInteger const RMQEmptyFrameSize = 8;

@interface RMQFrame ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQPayload> payload;
@end

@implementation RMQFrame

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                              payload:(id<RMQPayload>)payload {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.payload = payload;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
    char typeID             = [parser parseOctet];
    NSNumber *channelNumber = @([parser parseShortUInt]);
    UInt32 payloadSize      = [parser parseLongUInt];

    id <RMQPayload> payload;
    switch (typeID) {
        case RMQFrameTypeContentHeader:
            payload = [[RMQContentHeader alloc] initWithParser:parser];
            break;

        case RMQFrameTypeContentBody:
            payload = [[RMQContentBody alloc] initWithParser:parser payloadSize:payloadSize];
            break;

        case RMQFrameTypeHeartbeat:
            payload = [RMQHeartbeat new];
            break;

        default:
            payload = [[[RMQMethodDecoder alloc] initWithParser:parser] decode];
            break;
    }

    return [self initWithChannelNumber:channelNumber payload:payload];
}

- (NSData *)amqEncoded {
    NSMutableData *frameData = [NSMutableData new];
    NSArray *unencodedFrame = @[[[RMQOctet alloc] init:self.payload.frameTypeID.integerValue],
                                [[RMQShort alloc] init:self.channelNumber.integerValue],
                                [[RMQLong alloc] init:self.payload.amqEncoded.length],
                                self.payload,
                                [[RMQOctet alloc] init:0xCE]];
    for (id<RMQEncodable> part in unencodedFrame) {
        [frameData appendData:part.amqEncoded];
    }
    return frameData;
}

- (BOOL)isHeartbeat {
    return self.channelNumber.integerValue == 0 && [self.payload isKindOfClass:[RMQHeartbeat class]];
}

@end
