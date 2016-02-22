#import "AMQDecoder.h"
#import "AMQParser.h"
#import "AMQProtocolValues.h"
#import "AMQProtocolMethodMap.h"

@interface AMQDecoder ()

@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) const char *cursor;
@property (nonatomic, readwrite) const char *end;
@property (nonatomic, readwrite) AMQParser *parser;
@property (nonatomic, readwrite) NSNumber *typeID;
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
        self.parser    = [[AMQParser alloc] initWithData:self.data];
        self.typeID    = @([self.parser parseOctet].integerValue);
        self.channelID = @([self.parser parseShortUInt].integerValue);
        self.size      = [self.parser parseLongUInt];
        self.classID   = @([self.parser parseShortUInt].integerValue);
        self.methodID  = @([self.parser parseShortUInt].integerValue);
    }
    return self;
}

- (id)decode {
    Class methodClass = AMQProtocolMethodMap.methodMap[@[self.classID, self.methodID]];
    NSArray *frame = [methodClass frame];
    NSMutableArray *decodedFrame = [NSMutableArray new];
    for (int i = 0; i < frame.count; i++) {
        Class propertyClass = frame[i];
        decodedFrame[i] = [[propertyClass alloc] initWithCoder:self];
    }
    return [(id <AMQMethod>)[methodClass alloc] initWithDecodedFrame:decodedFrame];
}

- (id)decodeObjectForKey:(NSString *)key {
    if ([key isEqualToString:@"octet"]) {
        return [self.parser parseOctet];
    } else if ([key isEqualToString:@"field-table"]) {
        return [self.parser parseFieldTable];
    } else if ([key isEqualToString:@"shortstr"]) {
        return [self.parser parseShortString];
    } else if ([key isEqualToString:@"longstr"]) {
        return [self.parser parseLongString];
    } else if ([key isEqualToString:@"short"]) {
        return [self.parser parseShortUInt];
    } else if ([key isEqualToString:@"long"]) {
        return [self.parser parseLongUInt];
    } else {
        return @"Something very very bad happened";
    }
}

@end
