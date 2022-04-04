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

#import "RMQConnection.h"
#import "RMQAllocatedChannel.h"
#import "RMQFramesetValidator.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQUnallocatedChannel.h"
#import "RMQGCDSerialQueue.h"
#import "RMQProcessInfoNameGenerator.h"
#import "RMQFrame.h"
#import "RMQSuspendResumeDispatcher.h"
#import "RMQTransactionalConfirmations.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (atomic, readwrite) UInt16 maxCapacity;
@property (nonatomic, readwrite) NSMutableDictionary *channels;
@property (nonatomic, readwrite) NSNumber *syncTimeout;
@property (nonatomic, readwrite) RMQProcessInfoNameGenerator *nameGenerator;
@property (nonatomic, readwrite) NSNumber *dispatcherReenableDelay;
@end

@implementation RMQMultipleChannelAllocator
@synthesize sender;

- (instancetype)initWithMaxCapacity:(UInt16)limit
                 channelSyncTimeout:(NSNumber *)syncTimeout {
    self = [super init];
    if (self) {
        self.channels = [NSMutableDictionary new];
        self.maxCapacity = limit;
        self.channelNumber = 0;
        self.sender = nil;
        self.syncTimeout = syncTimeout;
        self.nameGenerator = [RMQProcessInfoNameGenerator new];
        self.dispatcherReenableDelay = @1;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)cleanupOnClose {
    for (id key in self.channels) {
        [[self.channels objectForKey:key] close];
    }
    [self.channels removeAllObjects];
   
}
- (id<RMQChannel>)allocate {
    id<RMQChannel> ch;
    @synchronized(self) {
        ch = self.unsafeAllocate;
    }
    return ch;
}

- (void)releaseChannelNumber:(NSNumber *)channelNumber {
    @synchronized(self) {
        [self unsafeReleaseChannelNumber:channelNumber];
    }
}

- (NSArray *)allocatedUserChannels {
    NSMutableArray *userChannels = [self.channels.allValues mutableCopy];
    [userChannels removeObjectAtIndex:0];
    return [userChannels sortedArrayUsingComparator:^NSComparisonResult(id<RMQChannel> ch1, id<RMQChannel> ch2) {
        return ch1.channelNumber.integerValue > ch2.channelNumber.integerValue;
    }];
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(RMQFrameset *)frameset {
    RMQAllocatedChannel *ch = self.channels[frameset.channelNumber];
    [ch handleFrameset:frameset];
}

# pragma mark - Private

- (id<RMQChannel>)unsafeAllocate {
    if (self.atCapacity) {
        return [RMQUnallocatedChannel new];
    } else if (self.atMaxIndex) {
        return self.previouslyReleasedChannel;
    } else {
        return self.newAllocation;
    }
}

- (void)unsafeReleaseChannelNumber:(NSNumber *)channelNumber {
    [self.channels removeObjectForKey:channelNumber];
}

- (id<RMQChannel>)newAllocation {
    RMQAllocatedChannel *ch = [self allocatedChannel:self.channelNumber];
    self.channelNumber++;
    return ch;
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < self.maxCapacity; i++) {
        if (!self.channels[@(i)]) {
            return [self allocatedChannel:i];
        }
    }
    return [RMQUnallocatedChannel new];
}

- (RMQAllocatedChannel *)allocatedChannel:(NSUInteger)channelNumber {
    RMQGCDSerialQueue *commandQueue = [self serialQueue:channelNumber type:@"commands"];
    [commandQueue suspend];
    RMQGCDSerialQueue *recoveryQueue = [self serialQueue:channelNumber type:@"recovery"];
    [recoveryQueue suspend];
    RMQGCDSerialQueue *enablementQueue = [self serialQueue:channelNumber type:@"enablement"];
    RMQGCDSerialQueue *confirmationTimeoutQueue = [self serialQueue:channelNumber type:@"confirmation-timeout"];

    RMQSuspendResumeDispatcher *dispatcher = [[RMQSuspendResumeDispatcher alloc] initWithSender:self.sender
                                                                                   commandQueue:commandQueue
                                                                                enablementQueue:enablementQueue
                                                                                    enableDelay:self.dispatcherReenableDelay];
    RMQTransactionalConfirmations *confirmations = [[RMQTransactionalConfirmations alloc] initWithDelayQueue:confirmationTimeoutQueue];

    RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(channelNumber)
                                                contentBodySize:@(self.sender.frameMax.integerValue - RMQEmptyFrameSize)
                                                     dispatcher:dispatcher
                                                  nameGenerator:self.nameGenerator
                                                      allocator:self
                                                  confirmations:confirmations];
    self.channels[@(channelNumber)] = ch;
    return ch;
}

- (BOOL)atCapacity {
    return self.channels.count == self.maxCapacity;
}

- (BOOL)atMaxIndex {
    return self.channelNumber == self.maxCapacity;
}

- (RMQGCDSerialQueue *)serialQueue:(UInt16)channelNumber
                              type:(NSString *)type {
    return [[RMQGCDSerialQueue alloc] initWithName:[NSString stringWithFormat:@"channel %d (%@)", channelNumber, type]];
}

@end
