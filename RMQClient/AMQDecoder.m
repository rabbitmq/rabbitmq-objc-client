#import "AMQDecoder.h"
#import "AMQParser.h"
#import "AMQProtocol.h"

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
    NSDictionary *keyTypes = @{@"10_10_version-major"     : @"octet",
                               @"10_10_version-minor"     : @"octet",
                               @"10_10_server-properties" : @"field-table",
                               @"10_10_mechanisms"        : @"longstr",
                               @"10_10_locales"           : @"longstr",
                               @"10_30_channel-max"       : @"short",
                               @"10_30_frame-max"         : @"long",
                               @"10_30_heartbeat"         : @"short",
                               @"10_41_known-hosts"       : @"shortstr"};
    NSString *keyType = keyTypes[key];
    if ([keyType isEqualToString:@"octet"]) {
        return [[AMQOctet alloc] init:[self.parser parseChar:&_cursor end:self.end].integerValue];
    } else if ([keyType isEqualToString:@"field-table"]) {
        return [[AMQFieldTable alloc] init:[self.parser parseFieldTable:&_cursor end:self.end]];
    } else if ([keyType isEqualToString:@"longstr"]) {
        return [[AMQLongString alloc] init:[self.parser parseLongString:&_cursor end:self.end]];
    } else if ([keyType isEqualToString:@"shortstr"]) {
        return [[AMQShortString alloc] init:[self.parser parseShortString:&_cursor end:self.end]];
    } else if ([keyType isEqualToString:@"short"]) {
        return [[AMQShortUInt alloc] init:[self.parser parseShortUInt:&_cursor end:self.end]];
    } else if ([keyType isEqualToString:@"long"]) {
        return [[AMQLongUInt alloc] init:[self.parser parseLongUInt:&_cursor end:self.end]];
    } else {
        @throw [NSString stringWithFormat:@"No parse function for %@ (%@)!", key, keyType];
    }
}

@end
