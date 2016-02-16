#import "AMQProtocolValues.h"

@protocol RMQFrameHandler
- (void)handleFrameset:(AMQFrame *)frameset;
@end
