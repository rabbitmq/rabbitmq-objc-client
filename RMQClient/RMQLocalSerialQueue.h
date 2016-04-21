#import <Foundation/Foundation.h>

@protocol RMQLocalSerialQueue <NSObject>

- (void)enqueue:(void (^)())operation;
- (void)blockingEnqueue:(void (^)())operation;
- (void)suspend;
- (void)resume;

@end
