#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@interface RMQSession : NSObject
- (void)start;
- (RMQChannel *)createChannel;
@end
