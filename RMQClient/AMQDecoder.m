#import "AMQDecoder.h"
#import "AMQParser.h"
#import "AMQProtocolValues.h"

@interface AMQDecoder ()

@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@property (nonatomic, readwrite) AMQParser *parser;

@end

@implementation AMQDecoder

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        NSUInteger headerLength = 1 + 2 + 4;
        NSUInteger classIDPlusMethodIDLength = 4;
        NSUInteger startIndex = headerLength + classIDPlusMethodIDLength;
        NSRange range = NSMakeRange(startIndex, data.length - startIndex);
        self.data = [data subdataWithRange:range];
        self.cursor = (const char *)self.data.bytes;
        self.end = (const char *)self.data.bytes + self.data.length;
        self.parser = [AMQParser new];
    }
    return self;
}

- (id)decodeObjectForKey:(NSString *)key {
    if ([key isEqualToString:@"octet"]) {
        return [self.parser parseOctet:&_cursor end:self.end];
    } else if ([key isEqualToString:@"field-table"]) {
        return [self.parser parseFieldTable:&_cursor end:self.end];
    } else if ([key isEqualToString:@"shortstr"]) {
        return [self.parser parseShortString:&_cursor end:self.end];
    } else if ([key isEqualToString:@"longstr"]) {
        return [self.parser parseLongString:&_cursor end:self.end];
    } else if ([key isEqualToString:@"short"]) {
        return [self.parser parseShortUInt:&_cursor end:self.end];
    } else if ([key isEqualToString:@"long"]) {
        return [self.parser parseLongUInt:&_cursor end:self.end];
    } else {
        return @"Something very very bad happened";
    }
}

@end
