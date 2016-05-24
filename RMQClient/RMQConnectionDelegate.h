#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@class RMQConnection;
@protocol RMQConnectionDelegate <NSObject>
- (void)      connection:(RMQConnection *)connection
failedToConnectWithError:(NSError *)error;
- (void)    connection:(RMQConnection *)connection
failedToWriteWithError:(NSError *)error;
- (void)   connection:(RMQConnection *)connection
disconnectedWithError:(NSError *)error;
- (void)willStartRecoveryWithConnection:(RMQConnection *)connection;
- (void)startingRecoveryWithConnection:(RMQConnection *)connection;
- (void)recoveredConnection:(RMQConnection *)connection;
- (void)channel:(id<RMQChannel>)channel
          error:(NSError *)error;
@end
