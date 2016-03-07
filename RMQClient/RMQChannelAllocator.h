#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQFrameHandler.h"

@protocol RMQChannelAllocator <NSObject, RMQFrameHandler>
- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender;
@end