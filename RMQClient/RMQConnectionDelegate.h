#import <Foundation/Foundation.h>

@class RMQConnection;
@protocol RMQConnectionDelegate <NSObject>
- (void)      connection:(RMQConnection *)connection
failedToConnectWithError:(NSError *)error;
- (void)      connection:(RMQConnection *)connection
     failedToOpenChannel:(id<RMQChannel>)channel
                   error:(NSError *)error;
- (void)    connection:(RMQConnection *)connection
failedToWriteWithError:(NSError *)error;
- (void)   connection:(RMQConnection *)connection
disconnectedWithError:(NSError *)error;
- (void)channel:(id<RMQChannel>)channel
          error:(NSError *)error;
@end
