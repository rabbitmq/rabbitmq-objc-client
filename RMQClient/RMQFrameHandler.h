#import "AMQProtocolValues.h"

@protocol RMQFrameHandler
- (void)handleFrameset:(AMQFrameset *)frameset;
@end
