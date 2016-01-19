#import "AMQParser.h"

@implementation AMQParser

- (AMQProtocolConnectionStart *)parse:(NSData *)data {
    NSRange range = NSMakeRange(4, data.length - 4); // ignore classID and methodID for now
    return [AMQProtocolConnectionStart decode:[data subdataWithRange:range]];
}

enum field_value_types {
    field_table = 'F',
    boolean = 't',
};

- (NSDictionary *)parseFieldTable:(const char **)cursor
                              end:(const char *)end {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    const char *start = *cursor;
    
    UInt32 tableLength = [self parseLongUInt:cursor end:end];
    // if (*cursor + tableLength >= end) error
    
    while (*cursor < start + tableLength && *cursor < end) {
        NSString *key = [self parseShortString:cursor end:end];
        
        enum field_value_types type = *((*cursor)++);
        switch (type) {
            case field_table:
                dict[key] = [self parseFieldTable:cursor end:end];
                break;
            case boolean:
                dict[key] = @([self parseBoolean:cursor end:end]);
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
