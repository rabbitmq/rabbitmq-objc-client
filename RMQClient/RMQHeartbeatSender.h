#import <Foundation/Foundation.h>

@protocol RMQHeartbeatSender <NSObject>

- (void (^)())startWithInterval:(NSNumber *)intervalSeconds;
- (void)stop;
- (void)signalActivity;

@end
