#import "RMQFramesetWaitResult.h"

@interface RMQFramesetWaitResult ()
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) RMQFrameset *frameset;
@end

@implementation RMQFramesetWaitResult

- (instancetype)initWithFrameset:(RMQFrameset *)frameset error:(NSError *)error {
    self = [super init];
    if (self) {
        self.frameset = frameset;
        self.error = error;
    }
    return self;
}

@end
