#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@protocol RMQChannelAllocator <NSObject>
- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender;
- (void)releaseChannelNumber:(NSNumber *)channelNumber;
@end