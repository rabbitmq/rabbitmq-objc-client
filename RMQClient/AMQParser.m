#import "AMQParser.h"

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

- (AMQTable *)parseFieldTable {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = self.cursor;
    
    AMQLong *tableLength = [self parseLongUInt];
    // if (*cursor + tableLength >= end) error
    
    while (self.cursor < start + tableLength.integerValue && self.cursor < self.end) {
        NSString *key = [self parseShortString].stringValue;
        
        enum AMQParserFieldValue type = *((self.cursor)++);
        switch (type) {
            case AMQParserFieldTable:
                dict[key] = [self parseFieldTable];
                break;
            case AMQParserBoolean:
                dict[key] = [self parseBoolean];
                break;
            case AMQParserShortString:
                dict[key] = [self parseShortString];
                break;
            case AMQParserLongString:
                dict[key] = [self parseLongString];
                break;
        }
    }
    return [[AMQTable alloc] init:dict];
}

- (AMQLong *)parseLongUInt {
    UInt32 value;
    value = CFSwapInt32BigToHost(*(UInt32 *)self.cursor);
    self.cursor += sizeof(value);

    return [[AMQLong alloc] init:value];
}

- (AMQShort *)parseShortUInt {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)self.cursor);
    self.cursor += sizeof(value);

    return [[AMQShort alloc] init:value];
}

- (AMQOctet *)parseOctet {
    return [[AMQOctet alloc] init:*((self.cursor)++)];
}

- (AMQShortstr *)parseShortString {
    unsigned int length = *((self.cursor)++);
    NSString *string = [NSString stringWithFormat:@"%.*s", length, self.cursor];
    self.cursor += length;
    
    return [[AMQShortstr alloc] init:string];
}

- (AMQLongstr *)parseLongString {
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
    
    return [[AMQLongstr alloc] init:string];
}

- (AMQBoolean *)parseBoolean {
    if (!self.cursor || self.cursor + 1 > self.end) {
        // throw or something
    }
    
    return [[AMQBoolean alloc] init:*((self.cursor)++) != 0];
}

@end
