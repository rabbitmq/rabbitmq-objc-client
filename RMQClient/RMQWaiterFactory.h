#import <Foundation/Foundation.h>
#import "RMQWaiter.h"

@protocol RMQWaiterFactory <NSObject>

- (id<RMQWaiter>)makeWithTimeout:(NSNumber *)timeoutSeconds;

@end
