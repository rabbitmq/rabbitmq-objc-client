#import "RMQParser.h"
#import "RMQValues.h"

enum RMQParserFieldValue {
    RMQParserFieldTable = 'F',
    RMQParserBoolean = 't',
    RMQParserShortString = 's',
    RMQParserLongString = 'S',
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

- (NSDictionary *)parseFieldTable {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = self.cursor;

    NSNumber *tableLength = @([self parseLongUInt]);
    // if (*cursor + tableLength >= end) error

    while (self.cursor < start + tableLength.integerValue && self.cursor < self.end) {
        NSString *key = [self parseShortString];

        enum RMQParserFieldValue type = *((self.cursor)++);
        switch (type) {
            case RMQParserFieldTable:
                dict[key] = [[RMQTable alloc] init:[self parseFieldTable]];
                break;
            case RMQParserBoolean:
                dict[key] = [[RMQBoolean alloc] init:[self parseBoolean]];
                break;
            case RMQParserShortString:
                dict[key] = [[RMQShortstr alloc] init:[self parseShortString]];
                break;
            case RMQParserLongString:
                dict[key] = [[RMQLongstr alloc] init:[self parseLongString]];
                break;
        }
    }
    return dict;
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

- (UInt16)parseShortUInt {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)self.cursor);
    self.cursor += sizeof(value);

    return value;
}

- (char)parseOctet {
    if (self.cursor + 1 > self.end) {
        return 0;
    } else {
        return *((self.cursor)++);
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

@end
