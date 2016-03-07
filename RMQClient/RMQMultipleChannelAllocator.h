#import <Foundation/Foundation.h>
#import "RMQChannelAllocator.h"

@interface RMQMultipleChannelAllocator : NSObject <RMQChannelAllocator, RMQFrameHandler>
- (instancetype)initWithSender:(id<RMQSender>)sender;
@end
