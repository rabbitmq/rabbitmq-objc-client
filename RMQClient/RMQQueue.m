#import "RMQQueue.h"
#import "AMQProtocolMethods.h"

@interface RMQQueue ()
@property (weak, nonatomic, readwrite) RMQChannel *channel;
@end

@implementation RMQQueue

- (instancetype)initWithChannel:(RMQChannel *)channel {
    self = [super init];
    if (self) {
        self.channel = channel;
    }
    return self;
}

- (RMQQueue *)publish:(NSString *)message {
    [self.channel send:self.amqPublish];
    return self;
}

- (id<RMQMessage>)pop {
    return [[RMQContentMessage alloc] initWithDeliveryInfo:@{@"consumer_tag": @"foo"}
                                                  metadata:@{@"foo": @"bar"}
                                                   content:@"Hello!"];
}

- (AMQProtocolBasicPublish *)amqPublish {
    return [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                     exchange:[[AMQShortstr alloc] init:@""]
                                                   routingKey:[[AMQShortstr alloc] init:@""]
                                                    mandatory:[[AMQBit alloc] init:0]
                                                    immediate:[[AMQBit alloc] init:0]];
}

@end
