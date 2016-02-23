#import "AMQMethodDecoder.h"
#import "AMQParser.h"
#import "AMQProtocolValues.h"
#import "AMQProtocolMethodMap.h"

@interface AMQMethodDecoder ()

@property (nonatomic, readwrite) AMQParser *parser;
@property (nonatomic, readwrite) NSNumber *typeID;
@property (nonatomic, readwrite) NSNumber *channelID;
@property (nonatomic, readwrite) NSNumber *size;
@property (nonatomic, readwrite) NSNumber *classID;
@property (nonatomic, readwrite) NSNumber *methodID;

@end

@implementation AMQMethodDecoder

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.parser    = [[AMQParser alloc] initWithData:data];
        self.typeID    = @([self.parser parseOctet]);
        self.channelID = [self.parser parseShortUInt];
        self.size      = @([self.parser parseLongUInt]);
    }
    return self;
}

- (id)decode {
    NSNumber *classID   = @([self.parser parseShortUInt].integerValue);
    NSNumber *methodID  = @([self.parser parseShortUInt].integerValue);
    Class methodClass = AMQProtocolMethodMap.methodMap[@[classID, methodID]];
    NSArray *frame = [methodClass frame];
    NSMutableArray *decodedFrame = [NSMutableArray new];
    for (int i = 0; i < frame.count; i++) {
        Class propertyClass = frame[i];
        decodedFrame[i] = [[propertyClass alloc] initWithParser:self.parser];
    }
    return [(id <AMQMethod>)[methodClass alloc] initWithDecodedFrame:decodedFrame];
}

@end
