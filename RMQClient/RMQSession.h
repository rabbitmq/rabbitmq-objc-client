#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "AMQTransport.h"

@interface RMQSession : NSObject
@property (copy, nonatomic, readonly) NSString *user;
@property (copy, nonatomic, readonly) NSString *password;
@property (copy, nonatomic, readonly) NSString *vhost;

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id <AMQTransport>)transport;
- (void)start;
- (void)close;
- (RMQChannel *)createChannel;
@end
