#import <Foundation/Foundation.h>
#import "RMQMessage.h"

@class RMQConnection;
@class RMQChannel;

@interface RMQQueue : NSObject
@property (nonnull, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithConnection:(nonnull RMQConnection *)connection
                                   channel:(nonnull RMQChannel *)channel;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (nonnull id<RMQMessage>)pop;
@end
