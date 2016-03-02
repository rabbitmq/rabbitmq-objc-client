#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@protocol RMQChannelAllocator <NSObject>
- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender;
@end