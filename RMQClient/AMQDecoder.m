#import "AMQDecoder.h"
#import "AMQParser.h"
#import "AMQProtocolValues.h"
#import "AMQProtocolMethodMap.h"

@interface AMQDecoder ()

@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@property (nonatomic, readwrite) AMQParser *parser;
@property (nonatomic, readwrite) AMQOctet *type;
@property (nonatomic, readwrite) NSNumber *channelID;
@property (nonatomic, readwrite) AMQLong *size;
@property (nonatomic, readwrite) NSNumber *classID;
@property (nonatomic, readwrite) NSNumber *methodID;

@end

@implementation AMQDecoder

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data      = data;
        self.cursor    = (const char *)self.data.bytes;
        self.end       = (const char *)self.data.bytes + self.data.length;
        self.parser    = [AMQParser new];
        self.type      = [self.parser parseOctet:&_cursor end:self.end];
        self.channelID = @([self.parser parseShortUInt:&_cursor end:self.end].integerValue);
        self.size      = [self.parser parseLongUInt:&_cursor end:self.end];
        self.classID   = @([self.parser parseShortUInt:&_cursor end:self.end].integerValue);
        self.methodID  = @([self.parser parseShortUInt:&_cursor end:self.end].integerValue);
    }
    return self;
}

- (id<AMQMethod>)decodedAMQMethod {
    Class methodClass = AMQProtocolMethodMap.methodMap[@[self.classID, self.methodID]];
    return [[methodClass alloc] initWithCoder:self];
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
