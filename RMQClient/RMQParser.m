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

#import "RMQParser.h"
#import "RMQTable.h"

// from https://www.rabbitmq.com/amqp-0-9-1-errata.html
// but without anything the Java client doesn't implement
typedef NS_ENUM(char, RMQParserFieldValue) {
    RMQParserBoolean       = 't',
    RMQParserSigned8Bit    = 'b',
    RMQParserSigned16Bit   = 's',
    RMQParserUnsigned16Bit = 'u',
    RMQParserSigned32Bit   = 'I',
    RMQParserUnsigned32Bit = 'i',
    RMQParserSigned64Bit   = 'l',
    RMQParser32BitFloat    = 'f',
    RMQParser64BitFloat    = 'd',
    RMQParserDecimal       = 'D',
    RMQParserLongString    = 'S',
    RMQParserArray         = 'A',
    RMQParserTimestamp     = 'T',
    RMQParserNestedTable   = 'F',
    RMQParserVoid          = 'V',
    RMQParserByteArray     = 'x',
};

@interface RMQValueForUnsupportedField : RMQValue <RMQFieldValue>
@end

@implementation RMQValueForUnsupportedField
- (NSData *)amqFieldValueType {
    return nil;
}
- (NSData *)amqEncoded {
    return [NSData data];
}
@end

@interface RMQParser ()
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@property (nonatomic, readwrite) NSData *data;
@end

@implementation RMQParser

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data   = data;
        self.cursor = (const char *)data.bytes;
        self.end    = (const char *)data.bytes + data.length;
    }
    return self;
}

- (NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)parseFieldTable {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = self.cursor;

    UInt32 length = [self parseLongUInt];

    while (self.cursor < start + length && self.cursor < self.end) {
        NSString *key = [self parseShortString];

        RMQParserFieldValue type = *(self.cursor++);
        RMQValue<RMQFieldValue> *value = [self parseValueForType:type];

        if ([value isKindOfClass:[RMQValueForUnsupportedField class]]) {
            return @{};
        }
        dict[key] = value;
    }

    return dict;
}

- (char)parseOctet {
    if (self.cursor + 1 > self.end) {
        return 0;
    } else {
        return *((self.cursor)++);
    }
}

- (UInt32)parseLongUInt {
    UInt32 value;
    value = CFSwapInt32BigToHost(*(UInt32 *)self.cursor);
    if (self.cursor + sizeof(value) > self.end) {
        return 0;
    } else {
        self.cursor += sizeof(value);
        return value;
    }
}

- (UInt64)parseLongLongUInt {
    UInt64 value;
    value = CFSwapInt64BigToHost(*(UInt64 *)self.cursor);
    if (self.cursor + sizeof(value) > self.end) {
        return 0;
    } else {
        self.cursor += sizeof(value);
        return value;
    }
}

- (NSDate *)parseTimestamp {
    NSTimeInterval interval = [self parseLongLongUInt];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (UInt16)parseShortUInt {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)self.cursor);
    if (self.cursor + sizeof(value) > self.end) {
        return 0;
    } else {
        self.cursor += sizeof(value);
        return value;
    }
}

- (BOOL)parseBoolean {
    return [self parseOctet] != 0;
}

- (NSString *)parseShortString {
    UInt8 length = *self.cursor;
    const char *expectedStringEnd = self.cursor + sizeof(length) + length;

    if (expectedStringEnd > self.end) {
        return @"";
    } else {
        self.cursor++;
        NSString *string = [NSString stringWithFormat:@"%.*s", length, self.cursor];
        self.cursor += length;

        return string;
    }
}

- (NSString *)parseLongString {
    if (self.cursor >= self.end) {
        return @"";
    }
    UInt32 length = CFSwapInt32BigToHost(*(UInt32 *)self.cursor);
    const char *expectedStringEnd = self.cursor + sizeof(length) + length;

    if (expectedStringEnd > self.end) {
        return @"";
    } else {
        self.cursor += sizeof(length);
        int readCharsLength = length;
        NSString *string = [NSString stringWithFormat:@"%.*s", readCharsLength, self.cursor];
        self.cursor += length;

        return string;
    }
}

- (NSData *)parseLength:(UInt32)length {
    return [NSData dataWithBytes:(void *)self.cursor length:length];
}

# pragma mark - Private

- (NSArray *)parseFieldArray {
    NSMutableArray *array = [NSMutableArray new];
    const char *start      = self.cursor;
    int32_t length         = [self parseLongInt];
    const char *endOfArray = start + sizeof(length) + length;

    while (self.cursor < endOfArray && self.cursor < self.end) {
        RMQParserFieldValue type = *(self.cursor++);
        [array addObject:[self parseValueForType:type]];
    }

    return array;
}

- (RMQValue<RMQFieldValue> *)parseValueForType:(RMQParserFieldValue)type {
    switch (type) {
        case RMQParserBoolean:
            return [[RMQBoolean alloc] init:[self parseBoolean]];
        case RMQParserSigned8Bit:
            return [[RMQSignedByte alloc] init:[self parseSignedByte]];
        case RMQParserSigned16Bit:
            return [[RMQSignedShort alloc] init:[self parseShortInt]];
        case RMQParserUnsigned16Bit:
            return [[RMQShort alloc] init:[self parseShortUInt]];
        case RMQParserSigned32Bit:
            return [[RMQSignedLong alloc] init:[self parseLongInt]];
        case RMQParserUnsigned32Bit:
            return [[RMQLong alloc] init:[self parseLongUInt]];
        case RMQParserSigned64Bit:
            return [[RMQSignedLonglong alloc] init:[self parseLongLongInt]];
        case RMQParser32BitFloat:
            return [[RMQFloat alloc] init:[self parseFloat]];
        case RMQParser64BitFloat:
            return [[RMQDouble alloc] init:[self parseDouble]];
        case RMQParserDecimal:
            [self parseDecimal];
            return [RMQDecimal new];
        case RMQParserLongString:
            return [[RMQLongstr alloc] init:[self parseLongString]];
        case RMQParserArray:
            return [[RMQArray alloc] init:[self parseFieldArray]];
        case RMQParserTimestamp:
            return [[RMQTimestamp alloc] init:[self parseTimestamp]];
        case RMQParserNestedTable:
            return [[RMQTable alloc] init:[self parseFieldTable]];
        case RMQParserVoid:
            return [RMQVoid new];
        case RMQParserByteArray:
            return [[RMQByteArray alloc] init:[self parseByteArray]];
        default:
            return [RMQValueForUnsupportedField new];
    }
}

- (int32_t)parseLongInt {
    int32_t value;
    value = CFSwapInt32BigToHost(*(int32_t *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (int64_t)parseLongLongInt {
    int64_t value;
    value = CFSwapInt64BigToHost(*(int64_t *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (float)parseFloat {
    float value;
    value = CFConvertFloatSwappedToHost(*(CFSwappedFloat32 *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (double)parseDouble {
    double value;
    value = CFConvertDoubleSwappedToHost(*(CFSwappedFloat64 *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (void)parseDecimal {
    [self parseOctet];
    [self parseLongInt];
}

- (int16_t)parseShortInt {
    int16_t value;
    value = CFSwapInt16BigToHost(*(int16_t *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (signed char)parseSignedByte {
    return *((self.cursor)++);
}

- (NSData *)parseByteArray {
    UInt32 length = [self parseLongUInt];
    NSData *data = [self parseLength:length];
    self.cursor += length;
    return data;
}

@end
