#import <Foundation/Foundation.h>

@protocol RMQClock <NSObject>

- (NSDate *)read;

@end
