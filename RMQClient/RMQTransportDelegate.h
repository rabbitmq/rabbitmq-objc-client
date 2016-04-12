#import <Foundation/Foundation.h>

@protocol RMQTransport;
@protocol RMQTransportDelegate <NSObject>
- (void)     transport:(id<RMQTransport>)transport
failedToWriteWithError:(NSError *)error;
- (void)    transport:(id<RMQTransport>)transport
disconnectedWithError:(NSError *)error;
@end
