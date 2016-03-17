#import "AMQParser.h"
#import "AMQValues.h"

enum AMQParserFieldValue {
    AMQParserFieldTable = 'F',
    AMQParserBoolean = 't',
    AMQParserShortString = 's',
    AMQParserLongString = 'S',
};

@interface AMQParser ()
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@property (nonatomic, readwrite) NSData *data;
@end

@implementation AMQParser

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

        enum AMQParserFieldValue type = *((self.cursor)++);
        switch (type) {
            case AMQParserFieldTable:
                dict[key] = [[AMQTable alloc] init:[self parseFieldTable]];
                break;
            case AMQParserBoolean:
                dict[key] = [[AMQBoolean alloc] init:[self parseBoolean]];
                break;
            case AMQParserShortString:
                dict[key] = [[AMQShortstr alloc] init:[self parseShortString]];
                break;
            case AMQParserLongString:
                dict[key] = [[AMQLongstr alloc] init:[self parseLongString]];
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
