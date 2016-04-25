#import <Foundation/Foundation.h>

@protocol RMQWaiter <NSObject>

- (void)done;
- (BOOL)timesOut;

@end
