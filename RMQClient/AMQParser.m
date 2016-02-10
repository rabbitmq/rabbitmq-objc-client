#import "AMQParser.h"

enum AMQParserFieldValue {
    AMQParserFieldTable = 'F',
    AMQParserBoolean = 't',
    AMQParserShortString = 's',
    AMQParserLongString = 'S',
};

@implementation AMQParser

- (AMQTable *)parseFieldTable:(const char **)cursor
                              end:(const char *)end {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = *cursor;
    
    AMQLong *tableLength = [self parseLongUInt:cursor end:end];
    // if (*cursor + tableLength >= end) error
    
    while (*cursor < start + tableLength.integerValue && *cursor < end) {
        NSString *key = [self parseShortString:cursor end:end].stringValue;
        
        enum AMQParserFieldValue type = *((*cursor)++);
        switch (type) {
            case AMQParserFieldTable:
                dict[key] = [self parseFieldTable:cursor end:end];
                break;
            case AMQParserBoolean:
                dict[key] = [self parseBoolean:cursor end:end];
                break;
            case AMQParserShortString:
                dict[key] = [self parseShortString:cursor end:end];
                break;
            case AMQParserLongString:
                dict[key] = [self parseLongString:cursor end:end];
                break;
        }
    }
    return [[AMQTable alloc] init:dict];
}

- (AMQLong *)parseLongUInt:(const char **)cursor
                       end:(const char *)end {
    UInt32 value;
    value = CFSwapInt32BigToHost(*(UInt32 *)*cursor);
    *cursor += sizeof(value);

    return [[AMQLong alloc] init:value];
}

- (AMQShort *)parseShortUInt:(const char **)cursor
                         end:(const char *)end {
    UInt16 value;
    value = CFSwapInt16BigToHost(*(UInt16 *)*cursor);
    *cursor += sizeof(value);

    return [[AMQShort alloc] init:value];
}

- (AMQOctet *)parseOctet:(const char **)cursor
                     end:(const char *)end {
    return [[AMQOctet alloc] init:*((*cursor)++)];
}

- (AMQShortstr *)parseShortString:(const char **)cursor
                              end:(const char *)end {
    unsigned int length = *((*cursor)++);
    NSString *string = [NSString stringWithFormat:@"%.*s", length, *cursor];
    *cursor += length;
    
    return [[AMQShortstr alloc] init:string];
}

- (AMQLongstr *)parseLongString:(const char **)cursor
                            end:(const char *)end {
    if (!cursor || !*cursor || *cursor + 4 > end) {
        // throw or something
    }
    
    unsigned int length = CFSwapInt32BigToHost(*(UInt32 *)*cursor);
    *cursor += sizeof(length);
    
    if (*cursor + length > end) {
        // TODO: What to do if length == 4GiB
    }
    NSString *string= [NSString stringWithFormat:@"%.*s", length, *cursor];
    *cursor += length;
    
    return [[AMQLongstr alloc] init:string];
}

- (AMQBoolean *)parseBoolean:(const char **)cursor
                         end:(const char *)end {
    if (!cursor || !*cursor || *cursor + 1 > end) {
        // throw or something
    }
    
    return [[AMQBoolean alloc] init:*((*cursor)++) != 0];
}

@end
