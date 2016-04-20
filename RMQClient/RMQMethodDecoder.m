#import "RMQMethodDecoder.h"
#import "RMQMethodMap.h"

@interface RMQMethodDecoder ()
@property (nonatomic, readwrite) RMQParser *parser;
@end

@implementation RMQMethodDecoder

- (instancetype)initWithParser:(RMQParser *)parser {
    self = [super init];
    if (self) {
        self.parser = parser;
    }
    return self;
}

- (id)decode {
    NSNumber *classID   = @([self.parser parseShortUInt]);
    NSNumber *methodID  = @([self.parser parseShortUInt]);
    Class methodClass = RMQMethodMap.methodMap[@[classID, methodID]];
    NSArray *propertyClasses = [methodClass propertyClasses];
    NSMutableArray *decodedFrame = [NSMutableArray new];
    for (int i = 0; i < propertyClasses.count; i++) {
        Class propertyClass = propertyClasses[i];
        decodedFrame[i] = [[propertyClass alloc] initWithParser:self.parser];
    }
    return [(id <RMQMethod>)[methodClass alloc] initWithDecodedFrame:decodedFrame];
}

@end
