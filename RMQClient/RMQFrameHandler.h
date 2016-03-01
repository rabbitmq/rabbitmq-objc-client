#import "AMQFrameset.h"

@protocol RMQFrameHandler
- (void)handleFrameset:(AMQFrameset *)frameset;
@end
