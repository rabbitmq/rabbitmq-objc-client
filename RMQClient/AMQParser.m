#import "AMQParser.h"
#import "AMQProtocolValues.h"

enum AMQParserFieldValue {
    AMQParserFieldTable = 'F',
    AMQParserBoolean = 't',
    AMQParserShortString = 's',
    AMQParserLongString = 'S',
};

@interface AMQParser ()
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@end

@implementation AMQParser

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.cursor = (const char *)data.bytes;
        self.end    = (const char *)data.bytes + data.length;
    }
    return self;
}

- (NSDictionary *)parseFieldTable {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = self.cursor;

    NSNumber *tableLength = [self parseLongUInt];
    // if (*cursor + tableLength >= end) error

    while (self.cursor < start + tableLength.integerValue && self.cursor < self.end) {
        NSString *key = [self parseShortString];

        enum AMQParserFieldValue type = *((self.cursor)++);
        switch (type) {
            case AMQParserFieldTable:
                dict[key] = [self parseFieldTable];
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

- (NSNumber *)parseLongUInt {
    UInt32 value;
    value = CFSwapInt32BigToHost(*(UInt32 *)self.cursor);
    self.cursor += sizeof(value);

    return @(value);
}

- (NSNumber *)parseLongLongUInt {
    UInt64 value;
    value = CFSwapInt64BigToHost(*(UInt64 *)self.cursor);
    self.cursor += sizeof(value);

    return @(value);
}

- (NSNumber *)parseShortUInt {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)self.cursor);
    self.cursor += sizeof(value);

    return @(value);
}

- (char)parseOctet {
    return *((self.cursor)++);
}

- (NSString *)parseShortString {
    unsigned int length = *((self.cursor)++);
    NSString *string = [NSString stringWithFormat:@"%.*s", length, self.cursor];
    self.cursor += length;

    return string;
}

- (NSString *)parseLongString {
    if (!self.cursor || self.cursor + 4 > self.end) {
        // throw or something
    }

    unsigned int length = CFSwapInt32BigToHost(*(UInt32 *)self.cursor);
    self.cursor += sizeof(length);

    if (self.cursor + length > self.end) {
        // TODO: What to do if length == 4GiB
    }
    NSString *string= [NSString stringWithFormat:@"%.*s", length, self.cursor];
    self.cursor += length;

    return string;
}

- (BOOL)parseBoolean {
    if (!self.cursor || self.cursor + 1 > self.end) {
        // throw or something
    }

    return *((self.cursor)++) != 0;
}

@end
