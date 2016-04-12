#import "RMQFramesetWaitResult.h"

@interface RMQFramesetWaitResult ()
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) AMQFrameset *frameset;
@end

@implementation RMQFramesetWaitResult

- (instancetype)initWithFrameset:(AMQFrameset *)frameset error:(NSError *)error {
    self = [super init];
    if (self) {
        self.frameset = frameset;
        self.error = error;
    }
    return self;
}

@end
