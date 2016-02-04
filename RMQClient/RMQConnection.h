#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQTransport.h"

@interface RMQConnection : NSObject<AMQReplyContext>
@property (copy, nonatomic, readonly) NSString *vhost;

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id <RMQTransport>)transport;
- (RMQConnection *)start;
- (void)close;
- (RMQChannel *)createChannel;
@end
