#import "AMQMethodDecoder.h"
#import "AMQProtocolMethodMap.h"

@interface AMQMethodDecoder ()
@property (nonatomic, readwrite) AMQParser *parser;
@end

@implementation AMQMethodDecoder

- (instancetype)initWithParser:(AMQParser *)parser {
    self = [super init];
    if (self) {
        self.parser = parser;
    }
    return self;
}

- (id)decode {
    NSNumber *classID   = @([self.parser parseShortUInt]);
    NSNumber *methodID  = @([self.parser parseShortUInt]);
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
