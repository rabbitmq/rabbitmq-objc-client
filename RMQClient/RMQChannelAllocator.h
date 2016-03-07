#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@protocol RMQChannelAllocator <NSObject>
- (id<RMQChannel>)allocate;
- (void)releaseChannelNumber:(NSNumber *)channelNumber;
@end