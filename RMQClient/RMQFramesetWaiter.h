#import <Foundation/Foundation.h>
#import "RMQFramesetWaitResult.h"

@protocol RMQFramesetWaiter <NSObject>
- (RMQFramesetWaitResult *)waitOn:(Class)methodClass;
- (void)fulfill:(AMQFrameset *)frameset;
@end
