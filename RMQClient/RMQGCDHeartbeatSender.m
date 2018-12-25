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

#import "RMQGCDHeartbeatSender.h"
#import "RMQHeartbeat.h"

@interface RMQGCDHeartbeatSender ()
@property (nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<RMQClock> clock;
@property (nonatomic, readwrite) dispatch_source_t timer;
@property (atomic, readwrite) NSDate *lastBeatAt;
@property (nonatomic, readwrite) dispatch_queue_t dispatchQueue;
@end

@implementation RMQGCDHeartbeatSender

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                            clock:(id<RMQClock>)clock {
    self = [super init];
    if (self) {
        self.clock = clock;
        self.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        self.transport = transport;
        [self signalActivity];
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void (^)(void))startWithInterval:(NSNumber *)intervalSeconds {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dispatchQueue);
    
    void (^eventHandler)(void) = ^{
        if ([self intervalPassed:intervalSeconds]) [self.transport write:self.heartbeatData];
    };
    double leewaySeconds = 1;
    dispatch_source_set_timer(self.timer,
                              DISPATCH_TIME_NOW,
                              intervalSeconds.doubleValue * NSEC_PER_SEC,
                              leewaySeconds * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, eventHandler);
    dispatch_resume(self.timer);

    return eventHandler;
}

- (void)stop {
    if (self.timer) dispatch_source_cancel(self.timer);
    self.timer = nil;
}

- (void)signalActivity {
    self.lastBeatAt = self.clock.read;
}

# pragma mark - Private

- (BOOL)intervalPassed:(NSNumber *)intervalSeconds {
    return [self.clock.read timeIntervalSinceDate:self.lastBeatAt] > intervalSeconds.doubleValue;
}

- (NSData *)heartbeatData {
    return [RMQHeartbeat new].amqEncoded;
}

@end
