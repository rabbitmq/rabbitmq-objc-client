#import "RMQExchange.h"
#import "RMQChannel.h"

@interface RMQExchange ()
@property (nonatomic, readwrite) id<RMQChannel> channel;
@end

@implementation RMQExchange

- (instancetype)initWithChannel:(id<RMQChannel>)channel
{
    self = [super init];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (void)publish:(NSString *)message routingKey:(NSString *)key persistent:(BOOL)isPersistent {
    [self.channel basicPublish:message
                    routingKey:key
                      exchange:@""
                    persistent:isPersistent];
}

- (void)publish:(NSString *)message routingKey:(NSString *)key {
    [self.channel basicPublish:message
                    routingKey:key
                      exchange:@""];
}

@end
