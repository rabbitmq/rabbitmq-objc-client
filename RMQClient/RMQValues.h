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

#import <Foundation/Foundation.h>
#import <JKVValue/JKVValue.h>
#import "RMQParser.h"
#import "RMQConnectionConfig.h"

@protocol RMQEncodable <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol RMQParseable <NSObject>
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser;
@end

@protocol RMQFieldValue <NSObject,RMQEncodable>
- (nonnull NSData *)amqFieldValueType;
@end

@interface RMQValue : JKVValue
@end

@interface RMQOctet : RMQValue<RMQEncodable,RMQParseable>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(char)octet;
@end

@interface RMQSignedByte : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) NSInteger integerValue;
- (nonnull instancetype)init:(signed char)byte;
@end

@interface RMQBoolean : RMQValue<RMQFieldValue,RMQParseable>
@property (nonatomic, readonly) BOOL boolValue;
- (nonnull instancetype)init:(BOOL)boolean;
@end

@interface RMQSignedShort : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) NSInteger integerValue;
- (nonnull instancetype)init:(NSInteger)val;
@end

@interface RMQShort : RMQValue<RMQFieldValue,RMQParseable>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface RMQShortShort : RMQOctet<RMQFieldValue,RMQParseable>
@end

@interface RMQSignedLong : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) NSInteger integerValue;
- (nonnull instancetype)init:(NSInteger)val;
@end

@interface RMQLong : RMQValue<RMQFieldValue,RMQParseable>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface RMQSignedLonglong : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) int64_t integerValue;
- (nonnull instancetype)init:(int64_t)val;
@end

@interface RMQLonglong : RMQValue<RMQFieldValue,RMQParseable>
@property (nonatomic, readonly) uint64_t integerValue;
- (nonnull instancetype)init:(uint64_t)val;
@end

@interface RMQFloat : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) float floatValue;
- (nonnull instancetype)init:(float)val;
@end

@interface RMQDouble : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) double doubleValue;
- (nonnull instancetype)init:(double)val;
@end

@interface RMQDecimal : RMQValue<RMQFieldValue>
@end

@interface RMQShortstr : RMQValue<RMQEncodable,RMQParseable>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface RMQLongstr : RMQValue<RMQFieldValue,RMQParseable>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface RMQArray : RMQValue<RMQFieldValue>
- (nonnull instancetype)init:(nonnull NSArray<RMQValue<RMQFieldValue> *> *)vals;
@end

@interface RMQTimestamp : RMQValue<RMQFieldValue,RMQParseable>
@property (nonnull, nonatomic, readonly) NSDate *dateValue;
- (nonnull instancetype)init:(nonnull NSDate *)date;
@end

@interface RMQVoid : RMQValue<RMQFieldValue>
@end

@interface RMQByteArray : RMQValue<RMQFieldValue>
- (nonnull instancetype)init:(nonnull NSData *)data;
@end

@interface RMQFieldValuePair : RMQValue<RMQEncodable>
- (nonnull instancetype)initWithFieldName:(nonnull NSString *)fieldName
                               fieldValue:(nonnull id <RMQEncodable,RMQFieldValue>)fieldValue;
@end

@interface RMQCredentials : RMQLongstr
- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;
@end

@protocol RMQPayload <NSObject, RMQEncodable>
- (nonnull NSNumber *)frameTypeID;
@end

@protocol RMQMethod <NSObject, RMQPayload>
+ (nonnull NSArray *)propertyClasses;
- (nonnull NSNumber *)classID;
- (nonnull NSNumber *)methodID;
- (nonnull Class)syncResponse;
- (nonnull instancetype)initWithDecodedFrame:(nonnull NSArray *)frame;
- (BOOL)hasContent;
@end

@protocol RMQBasicValue;
@interface RMQContentHeader : RMQValue<RMQPayload>
@property (nonnull, nonatomic, copy, readonly) NSNumber *bodySize;
@property (nonnull, nonatomic, readonly) NSArray<RMQValue<RMQBasicValue> *> *properties;
- (nonnull instancetype)initWithClassID:(nonnull NSNumber *)classID
                               bodySize:(nonnull NSNumber *)bodySize
                             properties:(nonnull NSArray *)properties;
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser;
@end

@interface RMQContentHeaderNone : RMQContentHeader
@end

@interface RMQContentBody : RMQValue<RMQPayload>
@property (nonnull, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSUInteger length;
- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser
                           payloadSize:(UInt32)payloadSize;
@end
