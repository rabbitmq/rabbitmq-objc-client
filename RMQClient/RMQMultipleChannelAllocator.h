#import <Foundation/Foundation.h>
#import "RMQChannelAllocator.h"

@interface RMQMultipleChannelAllocator : NSObject <RMQChannelAllocator>
- (instancetype)initWithSender:(id<RMQSender>)sender;
@end
