#import "RMQFrameset.h"

@protocol RMQFrameHandler
- (void)handleFrameset:(RMQFrameset *)frameset;
@end
