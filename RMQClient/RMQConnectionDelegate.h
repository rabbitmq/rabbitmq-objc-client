#import <Foundation/Foundation.h>

@class RMQConnection;
@protocol RMQConnectionDelegate <NSObject>
- (void)      connection:(RMQConnection *)connection
failedToConnectWithError:(NSError *)error;
@end
