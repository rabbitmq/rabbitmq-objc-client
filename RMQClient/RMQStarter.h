#import <Foundation/Foundation.h>

@protocol RMQStarter <NSObject>
- (void)start:(void (^)())completionHandler;
- (void)start;
@end
