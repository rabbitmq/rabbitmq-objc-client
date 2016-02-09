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
        NSRange range = NSMakeRange(4, data.length - 4); // ignore classID and methodID for now
        self.data = [data subdataWithRange:range];
        self.cursor = (const char *)self.data.bytes;
        self.end = (const char *)self.data.bytes + self.data.length;
        self.parser = [AMQParser new];
    }
    return self;
}

- (id)decodeObjectForKey:(NSString *)key {
    if ([key isEqualToString:@"octet"]) {
        return [[AMQOctet alloc] init:[self.parser parseChar:&_cursor end:self.end].integerValue];
    } else if ([key isEqualToString:@"field-table"]) {
        return [[AMQTable alloc] init:[self.parser parseFieldTable:&_cursor end:self.end]];
    } else if ([key isEqualToString:@"shortstr"]) {
        return [[AMQShortstr alloc] init:[self.parser parseShortString:&_cursor end:self.end]];
    } else if ([key isEqualToString:@"longstr"]) {
        return [[AMQLongstr alloc] init:[self.parser parseLongString:&_cursor end:self.end]];
    } else if ([key isEqualToString:@"short"]) {
        return [[AMQShort alloc] init:[self.parser parseShortUInt:&_cursor end:self.end]];
    } else if ([key isEqualToString:@"long"]) {
        return [[AMQLong alloc] init:[self.parser parseLongUInt:&_cursor end:self.end]];
    } else {
        return @"Something very very bad happened";
    }
}

@end
