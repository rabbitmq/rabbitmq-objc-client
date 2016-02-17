#import <Foundation/Foundation.h>
#import "RMQQueue.h"

@class RMQConnection;
@class RMQChannel;

@interface RMQQueueFactory : NSObject
- (instancetype)initWithConnection:(RMQConnection *)connection;
- (RMQQueue *)createWithChannel:(RMQChannel *)channel;
@end
