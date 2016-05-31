#import <Foundation/Foundation.h>
#import "RMQStarter.h"

@protocol RMQChannelAllocator;

@protocol RMQConnectionRecovery <NSObject>

@property (nonatomic, readonly) NSNumber *interval;

-  (void)recover:(id<RMQStarter>)connection
channelAllocator:(id<RMQChannelAllocator>)allocator
           error:(NSError *)error;

@end
