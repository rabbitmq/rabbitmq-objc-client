#import <Foundation/Foundation.h>
#import "RMQWaiter.h"
#import "RMQFramesetWaiter.h"

@protocol RMQWaiterFactory <NSObject>

- (id<RMQWaiter>)makeWithTimeout:(NSNumber *)timeoutSeconds;

@end
