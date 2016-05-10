#import "RMQConnectionDelegateThrower.h"

@implementation RMQConnectionDelegateThrower

- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error {
    @throw @"Connection disconnect";
}

- (void)connection:(RMQConnection *)connection failedToWriteWithError:(NSError *)error {
    @throw @"Connection failed to write";
}

- (void)connection:(RMQConnection *)connection failedToOpenChannel:(id<RMQChannel>)channel error:(NSError *)error {
    @throw [NSString stringWithFormat:@"Failed to open channel %@, %@", channel, error];
}

- (void)channel:(id<RMQChannel>)channel error:(NSError *)error {
    @throw [NSString stringWithFormat:@"Channel error %@", error];
}

@end
