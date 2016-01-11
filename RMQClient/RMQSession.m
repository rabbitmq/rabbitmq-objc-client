#import "RMQSession.h"

@interface RMQSession ()
@property (copy, nonatomic, readwrite) NSString *user;
@property (copy, nonatomic, readwrite) NSString *password;
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (nonatomic, readwrite) id <AMQTransport> transport;
@end

@implementation RMQSession

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id<AMQTransport>)transport {
    self = [super init];
    if (self) {
        self.user = user;
        self.password = password;
        self.vhost = vhost;
        self.transport = transport;
    }
    return self;
}

- (void)start {
    [self.transport write:[@"AMQP0091" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)close {
    
}

- (RMQChannel *)createChannel {
    return [RMQChannel new];
}

@end
