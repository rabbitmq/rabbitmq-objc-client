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

// This file is generated. Do not edit.
#import "RMQMethods.h"

@interface RMQConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) RMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) RMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *locales;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionStart

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class],
             [RMQOctet class],
             [RMQTable class],
             [RMQLongstr class],
             [RMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQConnectionStartOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithVersionMajor:(nonnull RMQOctet *)versionMajor
                                versionMinor:(nonnull RMQOctet *)versionMinor
                            serverProperties:(nonnull RMQTable *)serverProperties
                                  mechanisms:(nonnull RMQLongstr *)mechanisms
                                     locales:(nonnull RMQLongstr *)locales {
    self = [super init];
    if (self) {
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
        self.serverProperties = serverProperties;
        self.mechanisms = mechanisms;
        self.locales = locales;
        self.payloadArguments = @[self.versionMajor,
                                  self.versionMinor,
                                  self.serverProperties,
                                  self.mechanisms,
                                  self.locales];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.versionMajor = ((RMQOctet *)frame[0]);
        self.versionMinor = ((RMQOctet *)frame[1]);
        self.serverProperties = ((RMQTable *)frame[2]);
        self.mechanisms = ((RMQLongstr *)frame[3]);
        self.locales = ((RMQLongstr *)frame[4]);
        self.payloadArguments = @[self.versionMajor,
                                  self.versionMinor,
                                  self.serverProperties,
                                  self.mechanisms,
                                  self.locales];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionStartOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *response;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *locale;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionStartOk

+ (NSArray *)propertyClasses {
    return @[[RMQTable class],
             [RMQShortstr class],
             [RMQLongstr class],
             [RMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithClientProperties:(nonnull RMQTable *)clientProperties
                                       mechanism:(nonnull RMQShortstr *)mechanism
                                        response:(nonnull RMQLongstr *)response
                                          locale:(nonnull RMQShortstr *)locale {
    self = [super init];
    if (self) {
        self.clientProperties = clientProperties;
        self.mechanism = mechanism;
        self.response = response;
        self.locale = locale;
        self.payloadArguments = @[self.clientProperties,
                                  self.mechanism,
                                  self.response,
                                  self.locale];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.clientProperties = ((RMQTable *)frame[0]);
        self.mechanism = ((RMQShortstr *)frame[1]);
        self.response = ((RMQLongstr *)frame[2]);
        self.locale = ((RMQShortstr *)frame[3]);
        self.payloadArguments = @[self.clientProperties,
                                  self.mechanism,
                                  self.response,
                                  self.locale];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionSecure ()
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *challenge;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionSecure

+ (NSArray *)propertyClasses {
    return @[[RMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQConnectionSecureOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithChallenge:(nonnull RMQLongstr *)challenge {
    self = [super init];
    if (self) {
        self.challenge = challenge;
        self.payloadArguments = @[self.challenge];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.challenge = ((RMQLongstr *)frame[0]);
        self.payloadArguments = @[self.challenge];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionSecureOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *response;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionSecureOk

+ (NSArray *)propertyClasses {
    return @[[RMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithResponse:(nonnull RMQLongstr *)response {
    self = [super init];
    if (self) {
        self.response = response;
        self.payloadArguments = @[self.response];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.response = ((RMQLongstr *)frame[0]);
        self.payloadArguments = @[self.response];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionTune ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionTune

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQLong class],
             [RMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @30; }
- (Class)syncResponse       { return [RMQConnectionTuneOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.channelMax = ((RMQShort *)frame[0]);
        self.frameMax = ((RMQLong *)frame[1]);
        self.heartbeat = ((RMQShort *)frame[2]);
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionTuneOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionTuneOk

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQLong class],
             [RMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @31; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.channelMax = ((RMQShort *)frame[0]);
        self.frameMax = ((RMQLong *)frame[1]);
        self.heartbeat = ((RMQShort *)frame[2]);
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionOpen ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *reserved1;
@property (nonatomic, readwrite) RMQConnectionOpenOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionOpen

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @40; }
- (Class)syncResponse       { return [RMQConnectionOpenOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithVirtualHost:(nonnull RMQShortstr *)virtualHost
                                  reserved1:(nonnull RMQShortstr *)reserved1
                                    options:(RMQConnectionOpenOptions)options {
    self = [super init];
    if (self) {
        self.virtualHost = virtualHost;
        self.reserved1 = reserved1;
        self.options = options;
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.virtualHost = ((RMQShortstr *)frame[0]);
        self.reserved1 = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionOpenOk

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @41; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionClose ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionClose

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShort class],
             [RMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @50; }
- (Class)syncResponse       { return [RMQConnectionCloseOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.classId = classId;
        self.methodId = methodId;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((RMQShort *)frame[0]);
        self.replyText = ((RMQShortstr *)frame[1]);
        self.classId = ((RMQShort *)frame[2]);
        self.methodId = ((RMQShort *)frame[3]);
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionCloseOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @51; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionBlocked ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *reason;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionBlocked

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @60; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReason:(nonnull RMQShortstr *)reason {
    self = [super init];
    if (self) {
        self.reason = reason;
        self.payloadArguments = @[self.reason];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reason = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.reason];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConnectionUnblocked ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConnectionUnblocked

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @61; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelOpen ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelOpen

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQChannelOpenOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQLongstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelOpenOk

+ (NSArray *)propertyClasses {
    return @[[RMQLongstr class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQLongstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQLongstr *)frame[0]);
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelFlow ()
@property (nonatomic, readwrite) RMQChannelFlowOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelFlow

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQChannelFlowOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithOptions:(RMQChannelFlowOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((RMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelFlowOk ()
@property (nonatomic, readwrite) RMQChannelFlowOkOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelFlowOk

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithOptions:(RMQChannelFlowOkOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((RMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelClose ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelClose

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShort class],
             [RMQShort class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @40; }
- (Class)syncResponse       { return [RMQChannelCloseOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.classId = classId;
        self.methodId = methodId;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((RMQShort *)frame[0]);
        self.replyText = ((RMQShortstr *)frame[1]);
        self.classId = ((RMQShort *)frame[2]);
        self.methodId = ((RMQShort *)frame[3]);
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQChannelCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQChannelCloseOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @41; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeDeclare ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *type;
@property (nonatomic, readwrite) RMQExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeDeclare

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQExchangeDeclareOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                     type:(nonnull RMQShortstr *)type
                                  options:(RMQExchangeDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.type = type;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.exchange = ((RMQShortstr *)frame[1]);
        self.type = ((RMQShortstr *)frame[2]);
        self.options = ((RMQOctet *)frame[3]).integerValue;
        self.arguments = ((RMQTable *)frame[4]);
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeDeclareOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeDeclareOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeDelete ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonatomic, readwrite) RMQExchangeDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeDelete

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQExchangeDeleteOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                  options:(RMQExchangeDeleteOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.exchange = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeDeleteOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeDeleteOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeBind ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) RMQExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeBind

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @30; }
- (Class)syncResponse       { return [RMQExchangeBindOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeBindOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.destination = ((RMQShortstr *)frame[1]);
        self.source = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.options = ((RMQOctet *)frame[4]).integerValue;
        self.arguments = ((RMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeBindOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @31; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeUnbind ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) RMQExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeUnbind

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @40; }
- (Class)syncResponse       { return [RMQExchangeUnbindOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeUnbindOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.destination = ((RMQShortstr *)frame[1]);
        self.source = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.options = ((RMQOctet *)frame[4]).integerValue;
        self.arguments = ((RMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQExchangeUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQExchangeUnbindOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @51; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueDeclare ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonatomic, readwrite) RMQQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueDeclare

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQQueueDeclareOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.arguments = ((RMQTable *)frame[3]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueDeclareOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) RMQLong *messageCount;
@property (nonnull, copy, nonatomic, readwrite) RMQLong *consumerCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueDeclareOk

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class],
             [RMQLong class],
             [RMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithQueue:(nonnull RMQShortstr *)queue
                         messageCount:(nonnull RMQLong *)messageCount
                        consumerCount:(nonnull RMQLong *)consumerCount {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.messageCount = messageCount;
        self.consumerCount = consumerCount;
        self.payloadArguments = @[self.queue,
                                  self.messageCount,
                                  self.consumerCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.queue = ((RMQShortstr *)frame[0]);
        self.messageCount = ((RMQLong *)frame[1]);
        self.consumerCount = ((RMQLong *)frame[2]);
        self.payloadArguments = @[self.queue,
                                  self.messageCount,
                                  self.consumerCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueBind ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) RMQQueueBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueBind

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQQueueBindOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQQueueBindOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.exchange = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.options = ((RMQOctet *)frame[4]).integerValue;
        self.arguments = ((RMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueBindOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueUnbind ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueUnbind

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @50; }
- (Class)syncResponse       { return [RMQQueueUnbindOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.exchange = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.arguments = ((RMQTable *)frame[4]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueUnbindOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @51; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueuePurge ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonatomic, readwrite) RMQQueuePurgeOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueuePurge

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @30; }
- (Class)syncResponse       { return [RMQQueuePurgeOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueuePurgeOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueuePurgeOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueuePurgeOk

+ (NSArray *)propertyClasses {
    return @[[RMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @31; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.messageCount = ((RMQLong *)frame[0]);
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueDelete ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonatomic, readwrite) RMQQueueDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueDelete

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @40; }
- (Class)syncResponse       { return [RMQQueueDeleteOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeleteOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQQueueDeleteOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQQueueDeleteOk

+ (NSArray *)propertyClasses {
    return @[[RMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @41; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.messageCount = ((RMQLong *)frame[0]);
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicQos ()
@property (nonnull, copy, nonatomic, readwrite) RMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readwrite) RMQShort *prefetchCount;
@property (nonatomic, readwrite) RMQBasicQosOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicQos

+ (NSArray *)propertyClasses {
    return @[[RMQLong class],
             [RMQShort class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQBasicQosOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithPrefetchSize:(nonnull RMQLong *)prefetchSize
                               prefetchCount:(nonnull RMQShort *)prefetchCount
                                     options:(RMQBasicQosOptions)options {
    self = [super init];
    if (self) {
        self.prefetchSize = prefetchSize;
        self.prefetchCount = prefetchCount;
        self.options = options;
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.prefetchSize = ((RMQLong *)frame[0]);
        self.prefetchCount = ((RMQShort *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicQosOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicQosOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicConsume ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *consumerTag;
@property (nonatomic, readwrite) RMQBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicConsume

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class],
             [RMQTable class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQBasicConsumeOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                              consumerTag:(nonnull RMQShortstr *)consumerTag
                                  options:(RMQBasicConsumeOptions)options
                                arguments:(nonnull RMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.consumerTag = consumerTag;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.consumerTag = ((RMQShortstr *)frame[2]);
        self.options = ((RMQOctet *)frame[3]).integerValue;
        self.arguments = ((RMQTable *)frame[4]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicConsumeOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicConsumeOk

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicCancel ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *consumerTag;
@property (nonatomic, readwrite) RMQBasicCancelOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicCancel

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @30; }
- (Class)syncResponse       { return [RMQBasicCancelOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                    options:(RMQBasicCancelOptions)options {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.options = options;
        self.payloadArguments = @[self.consumerTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((RMQShortstr *)frame[0]);
        self.options = ((RMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.consumerTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicCancelOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicCancelOk

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @31; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicPublish ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) RMQBasicPublishOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicPublish

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @40; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQBasicPublishOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.exchange = ((RMQShortstr *)frame[1]);
        self.routingKey = ((RMQShortstr *)frame[2]);
        self.options = ((RMQOctet *)frame[3]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicReturn ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicReturn

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @50; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }

- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((RMQShort *)frame[0]);
        self.replyText = ((RMQShortstr *)frame[1]);
        self.exchange = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicDeliver ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) RMQLonglong *deliveryTag;
@property (nonatomic, readwrite) RMQBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicDeliver

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class],
             [RMQLonglong class],
             [RMQOctet class],
             [RMQShortstr class],
             [RMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @60; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }

- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                deliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicDeliverOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((RMQShortstr *)frame[0]);
        self.deliveryTag = ((RMQLonglong *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.exchange = ((RMQShortstr *)frame[3]);
        self.routingKey = ((RMQShortstr *)frame[4]);
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicGet ()
@property (nonnull, copy, nonatomic, readwrite) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *queue;
@property (nonatomic, readwrite) RMQBasicGetOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicGet

+ (NSArray *)propertyClasses {
    return @[[RMQShort class],
             [RMQShortstr class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @70; }
- (Class)syncResponse       { return [RMQBasicGetOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQBasicGetOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShort *)frame[0]);
        self.queue = ((RMQShortstr *)frame[1]);
        self.options = ((RMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicGetOk ()
@property (nonnull, copy, nonatomic, readwrite) RMQLonglong *deliveryTag;
@property (nonatomic, readwrite) RMQBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) RMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicGetOk

+ (NSArray *)propertyClasses {
    return @[[RMQLonglong class],
             [RMQOctet class],
             [RMQShortstr class],
             [RMQShortstr class],
             [RMQLong class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @71; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicGetOkOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey
                               messageCount:(nonnull RMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.messageCount = messageCount;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey,
                                  self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((RMQLonglong *)frame[0]);
        self.options = ((RMQOctet *)frame[1]).integerValue;
        self.exchange = ((RMQShortstr *)frame[2]);
        self.routingKey = ((RMQShortstr *)frame[3]);
        self.messageCount = ((RMQLong *)frame[4]);
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey,
                                  self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicGetEmpty ()
@property (nonnull, copy, nonatomic, readwrite) RMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicGetEmpty

+ (NSArray *)propertyClasses {
    return @[[RMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @72; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((RMQShortstr *)frame[0]);
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicAck ()
@property (nonnull, copy, nonatomic, readwrite) RMQLonglong *deliveryTag;
@property (nonatomic, readwrite) RMQBasicAckOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicAck

+ (NSArray *)propertyClasses {
    return @[[RMQLonglong class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @80; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicAckOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((RMQLonglong *)frame[0]);
        self.options = ((RMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicReject ()
@property (nonnull, copy, nonatomic, readwrite) RMQLonglong *deliveryTag;
@property (nonatomic, readwrite) RMQBasicRejectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicReject

+ (NSArray *)propertyClasses {
    return @[[RMQLonglong class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @90; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicRejectOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((RMQLonglong *)frame[0]);
        self.options = ((RMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicRecoverAsync ()
@property (nonatomic, readwrite) RMQBasicRecoverAsyncOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicRecoverAsync

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @100; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithOptions:(RMQBasicRecoverAsyncOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((RMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicRecover ()
@property (nonatomic, readwrite) RMQBasicRecoverOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicRecover

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @110; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithOptions:(RMQBasicRecoverOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((RMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicRecoverOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicRecoverOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @111; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQBasicNack ()
@property (nonnull, copy, nonatomic, readwrite) RMQLonglong *deliveryTag;
@property (nonatomic, readwrite) RMQBasicNackOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQBasicNack

+ (NSArray *)propertyClasses {
    return @[[RMQLonglong class],
             [RMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @120; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicNackOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((RMQLonglong *)frame[0]);
        self.options = ((RMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxSelect ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxSelect

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQTxSelectOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxSelectOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxCommit ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxCommit

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @20; }
- (Class)syncResponse       { return [RMQTxCommitOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxCommitOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxCommitOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @21; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxRollback ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxRollback

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @30; }
- (Class)syncResponse       { return [RMQTxRollbackOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQTxRollbackOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQTxRollbackOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @31; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConfirmSelect ()
@property (nonatomic, readwrite) RMQConfirmSelectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConfirmSelect

+ (NSArray *)propertyClasses {
    return @[[RMQOctet class]];
}
- (NSNumber *)classID       { return @85; }
- (NSNumber *)methodID      { return @10; }
- (Class)syncResponse       { return [RMQConfirmSelectOk class]; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }

- (nonnull instancetype)initWithOptions:(RMQConfirmSelectOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((RMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[RMQOctet alloc] init:self.options]];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface RMQConfirmSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation RMQConfirmSelectOk

+ (NSArray *)propertyClasses {
    return @[];
}
- (NSNumber *)classID       { return @85; }
- (NSNumber *)methodID      { return @11; }
- (Class)syncResponse       { return nil; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<RMQEncodable>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

