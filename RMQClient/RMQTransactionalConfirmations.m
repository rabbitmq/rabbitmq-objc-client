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

#import "RMQTransactionalConfirmations.h"
#import "RMQConfirmationTransaction.h"

@interface RMQTransactionalConfirmations ()
@property (nonatomic, readwrite) NSUInteger offset;
@property (nonatomic, readwrite) NSUInteger nextPublishSequenceNumber;
@property (nonatomic, readwrite) NSMutableArray *transactions;
@property (nonatomic, readwrite) NSUInteger transactionIndex;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> delayQueue;
@end

@implementation RMQTransactionalConfirmations

- (instancetype)initWithDelayQueue:(id<RMQLocalSerialQueue>)queue {
    self = [super init];
    if (self) {
        self.offset = 0;
        self.nextPublishSequenceNumber = 0;
        self.transactions = [NSMutableArray new];
        self.delayQueue = queue;
        [self addTransaction];
        self.transactionIndex = 0;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)enable {
    self.nextPublishSequenceNumber = 1;
}

- (BOOL)isEnabled {
    return self.nextPublishSequenceNumber > 0;
}

- (void)recover {
    self.offset = self.nextPublishSequenceNumber - 1;
}

- (NSNumber *)addPublication {
    NSNumber *publicationSequenceNumber = @(self.nextPublishSequenceNumber);
    if (self.isEnabled) {
        [self.currentTransaction addUnconfirmed:publicationSequenceNumber];
        self.nextPublishSequenceNumber++;
    }
    return publicationSequenceNumber;
}

- (void)addCallbackWithTimeout:(NSNumber *)timeoutInSecs
                      callback:(RMQConfirmationCallback)callback {
    [self.currentTransaction setCallback:callback
                                 timeout:timeoutInSecs];
    [self.currentTransaction completeIfReady];
    [self addTransaction];
}

- (void)ack:(RMQBasicAck *)ack {
    for (NSNumber *tag in [self offsetTags:ack]) {
        [[self transactionForUnconfirmedTag:tag] ack:tag];
    }
}

- (void)nack:(RMQBasicNack *)nack {
    for (NSNumber *tag in [self offsetTags:nack]) {
        [[self transactionForUnconfirmedTag:tag] nack:tag];
    }
}

#pragma mark - Private

- (RMQConfirmationTransaction *)transactionForUnconfirmedTag:(NSNumber *)tag {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(RMQConfirmationTransaction *tx, NSDictionary<NSString *,id> * bindings) {
        return [tx isUnconfirmed:tag];
    }];
    NSArray *filtered = [self.transactions filteredArrayUsingPredicate:pred];
    return filtered.count > 0 ? filtered[0] : nil;
}

- (RMQConfirmationTransaction *)currentTransaction {
    return self.transactions[self.transactionIndex];
}

- (void)addTransaction {
    [self.transactions addObject:[[RMQConfirmationTransaction alloc] initWithDelayQueue:self.delayQueue]];
    self.transactionIndex++;
}

- (NSArray *)offsetTags:(id)ackOrNack {
    RMQBasicAck *ack = (RMQBasicAck *)ackOrNack;
    uint64_t highestTag = ack.deliveryTag.integerValue;
    BOOL isMultiple = ack.options & RMQBasicAckMultiple;
    uint64_t lowestTag = isMultiple ? 1 : highestTag;

    NSMutableArray *tags = [NSMutableArray new];
    for (uint64_t tag = lowestTag; tag <= highestTag; tag++) {
        [tags addObject:@(tag + self.offset)];
    }
    return tags;
}

@end
