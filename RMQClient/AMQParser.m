#import "AMQParser.h"

enum AMQParserFieldValue {
    AMQParserFieldTable = 'F',
    AMQParserBoolean = 't',
    AMQParserShortString = 's',
    AMQParserLongString = 'S',
};

@implementation AMQParser

- (NSDictionary *)parseFieldTable:(const char **)cursor
                              end:(const char *)end {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = *cursor;
    
    UInt32 tableLength = [self parseLongUInt:cursor end:end];
    // if (*cursor + tableLength >= end) error
    
    while (*cursor < start + tableLength && *cursor < end) {
        NSString *key = [self parseShortString:cursor end:end];
        
        enum AMQParserFieldValue type = *((*cursor)++);
        switch (type) {
            case AMQParserFieldTable:
                dict[key] = [self parseFieldTable:cursor end:end];
                break;
            case AMQParserBoolean:
                dict[key] = @([self parseBoolean:cursor end:end]);
                break;
            case AMQParserShortString:
                dict[key] = [self parseShortString:cursor end:end];
                break;
            case AMQParserLongString:
                dict[key] = [self parseLongString:cursor end:end];
                break;
        }
    }
    return dict;
}

- (UInt32)parseLongUInt:(const char **)cursor
                    end:(const char *)end {
    UInt32 value;
    value = CFSwapInt32BigToHost(*(UInt32 *)*cursor);
    *cursor += sizeof(value);

    return value;
}

- (NSString *)parseShortString:(const char **)cursor
                           end:(const char *)end {
    unsigned int length = *((*cursor)++);
    NSString *string = [NSString stringWithFormat:@"%.*s", length, *cursor];
    *cursor += length;
    
    return string;
}

- (NSString *)parseLongString:(const char **)cursor
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
    
    return string;
}

- (BOOL)parseBoolean:(const char **)cursor
                 end:(const char *)end {
    if (!cursor || !*cursor || *cursor + 1 > end) {
        // throw or something
    }
    
    return *((*cursor)++) != 0;
}

@end
