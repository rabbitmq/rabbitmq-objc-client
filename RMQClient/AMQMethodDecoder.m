#import "AMQMethodDecoder.h"
#import "AMQMethodMap.h"

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
    Class methodClass = AMQMethodMap.methodMap[@[classID, methodID]];
    NSArray *propertyClasses = [methodClass propertyClasses];
    NSMutableArray *decodedFrame = [NSMutableArray new];
    for (int i = 0; i < propertyClasses.count; i++) {
        Class propertyClass = propertyClasses[i];
        decodedFrame[i] = [[propertyClass alloc] initWithParser:self.parser];
    }
    return [(id <AMQMethod>)[methodClass alloc] initWithDecodedFrame:decodedFrame];
}

@end
