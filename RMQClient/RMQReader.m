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

#import "RMQReader.h"
#import "RMQFrame.h"
#import "RMQMethodDecoder.h"

@interface RMQReader ()
@property (nonatomic, readwrite) id<RMQTransport>transport;
@property (nonatomic, readwrite) id<RMQFrameHandler>frameHandler;
@end

@implementation RMQReader

- (instancetype)initWithTransport:(id<RMQTransport>)transport frameHandler:(id<RMQFrameHandler>)frameHandler {
    self = [super init];
    if (self) {
        self.transport = transport;
        self.frameHandler = frameHandler;
    }
    return self;
}

- (void)run {
    [self.transport readFrame:^(NSData * _Nonnull methodData) {
        // executing on a concurrent queue
        
        RMQFrame *frame = [self frameWithData:methodData];

        if (frame.isHeartbeat) {
            [self run];
        } else {
            [self handleMethodFrame:frame];
        }
    }];
}

# pragma mark - Private

- (void)handleMethodFrame:(RMQFrame *)frame {
    id<RMQMethod> method = (id<RMQMethod>)frame.payload;

    if (method.hasContent) {
        [self.transport readFrame:^(NSData * _Nonnull headerData) {
            RMQFrame *headerFrame = [self frameWithData:headerData];
            RMQContentHeader *header = (RMQContentHeader *)headerFrame.payload;

            RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                        method:method
                                                                 contentHeader:header
                                                                 contentBodies:@[]];
            if ([header.bodySize isEqualToNumber:@0]) {
                [self.frameHandler handleFrameset:frameset];
            } else {
                [self readBodiesForIncompleteFrameset:frameset];
            }
        }];
    } else {
        RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                    method:method];
        [self.frameHandler handleFrameset:frameset];
    }
}

- (void)readBodiesForIncompleteFrameset:(RMQFrameset *)contentFrameset {
    [self.transport readFrame:^(NSData * _Nonnull data) {
        RMQFrame *frame = [self frameWithData:data];

        if ([frame.payload isKindOfClass:[RMQContentBody class]]) {
            [self frameset:contentFrameset
              addBodyFrame:frame];
        } else {
            [self.frameHandler handleFrameset:contentFrameset];
            RMQFrameset *nonContentFrameset = [[RMQFrameset alloc] initWithChannelNumber:contentFrameset.channelNumber
                                                                                  method:(id <RMQMethod>)frame.payload];
            [self.frameHandler handleFrameset:nonContentFrameset];
        }
    }];
}

- (void)frameset:(RMQFrameset *)frameset
    addBodyFrame:(RMQFrame *)newFrame {
    RMQFrameset *combinedFrameset = [frameset addBody:(RMQContentBody *)newFrame.payload];

    if (frameset.contentHeader.bodySize.integerValue == combinedFrameset.contentData.length) {
        [self.frameHandler handleFrameset:combinedFrameset];
    } else {
        [self readBodiesForIncompleteFrameset:combinedFrameset];
    }
}

- (RMQFrame *)frameWithData:(NSData *)data {
    RMQParser *parser = [[RMQParser alloc] initWithData:data];
    return [[RMQFrame alloc] initWithParser:parser];
}

@end
