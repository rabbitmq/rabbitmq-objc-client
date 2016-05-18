#import "RMQConsumer.h"
#import "RMQChannel.h"

@interface RMQConsumer ()
@property (nonatomic, readwrite) NSString *tag;
@property (nonatomic, readwrite) id<RMQChannel> channel;
@property (nonatomic, readwrite) RMQConsumerDeliveryHandler handler;
@end

@implementation RMQConsumer

- (instancetype)initWithConsumerTag:(NSString *)tag
                            handler:(RMQConsumerDeliveryHandler)handler
                            channel:(id<RMQChannel>)channel {
    self = [super init];
    if (self) {
        self.tag = tag;
        self.handler = handler;
        self.channel = channel;
    }
    return self;
}

- (void)cancel {
    [self.channel basicCancel:self.tag];
}

@end
