#import <Foundation/Foundation.h>
#import "RMQConnectionDelegate.h"

@interface RMQQueuingConnectionDelegateProxy : NSObject <RMQConnectionDelegate>

- (instancetype)initWithDelegate:(id<RMQConnectionDelegate>)delegate
                           queue:(dispatch_queue_t)queue;

@end
