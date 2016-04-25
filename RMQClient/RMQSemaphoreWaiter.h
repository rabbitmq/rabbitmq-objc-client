#import <Foundation/Foundation.h>
#import "RMQWaiter.h"

@interface RMQSemaphoreWaiter : NSObject <RMQWaiter>

- (instancetype)initWithTimeout:(NSNumber *)timeoutSeconds;

@end
