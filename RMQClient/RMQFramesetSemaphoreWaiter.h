#import <Foundation/Foundation.h>
#import "RMQFramesetWaiter.h"

@interface RMQFramesetSemaphoreWaiter : NSObject <RMQFramesetWaiter>
- (instancetype)initWithSyncTimeout:(NSNumber *)syncTimeout;
@end