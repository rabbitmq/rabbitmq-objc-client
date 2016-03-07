#import <Foundation/Foundation.h>
#import "RMQChannelAllocator.h"
#import "RMQSender.h"

@interface RMQChannel1Allocator : NSObject<RMQChannelAllocator, RMQFrameHandler>
- (instancetype)initWithSender:(id<RMQSender>)sender;
@end
