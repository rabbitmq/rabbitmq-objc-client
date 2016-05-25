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
        dict[key] = [self parseValueForType:type];
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
    self.cursor += sizeof(value);

    return value;
}

- (UInt64)parseLongLongUInt {
    UInt64 value;
    value = CFSwapInt64BigToHost(*(UInt64 *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (NSDate *)parseTimestamp {
    NSTimeInterval interval = [self parseLongLongUInt];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (UInt16)parseShortUInt {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)self.cursor);
    self.cursor += sizeof(value);

    return value;
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
    const char *start = self.cursor;

    UInt32 length = [self parseLongInt];

    while (self.cursor < start + length && self.cursor < self.end) {
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
