#import "RMQQueueFactory.h"

@interface RMQQueueFactory ()
@property (nonatomic, readwrite) RMQConnection *connection;
@end

@implementation RMQQueueFactory

- (instancetype)initWithConnection:(RMQConnection *)connection {
    self = [super init];
    if (self) {
        self.connection = connection;
    }
    return self;
}

- (RMQQueue *)createWithChannel:(RMQChannel *)channel {
    return [[RMQQueue alloc] initWithConnection:self.connection channel:channel];
}

@end
