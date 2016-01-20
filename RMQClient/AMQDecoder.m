#import "AMQDecoder.h"
#import "AMQParser.h"

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
        self.data = data;
        self.cursor = (const char *)data.bytes;
        self.end = (const char *)data.bytes + data.length;
        self.parser = [AMQParser new];
    }
    return self;
}

- (id)decodeObjectForKey:(NSString *)key {
    NSDictionary *keyTypes = @{@"10_10_version-major"     : @"octet",
                               @"10_10_version-minor"     : @"octet",
                               @"10_10_server-properties" : @"field-table",
                               @"10_10_mechanisms"        : @"longstr",
                               @"10_10_locales"           : @"longstr"};
    NSString *keyType = keyTypes[key];
    if ([keyType isEqualToString:@"octet"]) {
        return [self.parser parseChar:&_cursor end:self.end];
    } else if ([keyType isEqualToString:@"field-table"]) {
        return [self.parser parseFieldTable:&_cursor end:self.end];
    } else if ([keyType isEqualToString:@"longstr"]) {
        return [self.parser parseLongString:&_cursor end:self.end];
    } else {
        return NSNull.null;
    }
}

@end
