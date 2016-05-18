#import <Foundation/Foundation.h>

typedef void (^RMQOperation)();

@protocol RMQLocalSerialQueue <NSObject>

- (void)enqueue:(RMQOperation)operation;
- (void)blockingEnqueue:(RMQOperation)operation;
- (void)delayedBy:(NSNumber *)delay
          enqueue:(RMQOperation)operation;
- (void)suspend;
- (void)resume;

@end
