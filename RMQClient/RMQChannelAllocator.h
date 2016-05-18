#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQSender.h"

@protocol RMQChannelAllocator <NSObject>
@property (nonatomic, readwrite) id<RMQSender> sender;
- (id<RMQChannel>)allocate;
- (void)releaseChannelNumber:(NSNumber *)channelNumber;
- (NSArray<id<RMQChannel>> *)allocatedUserChannels;
@end