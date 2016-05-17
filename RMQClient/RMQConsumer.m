#import "RMQConsumer.h"
#import "RMQChannel.h"

@interface RMQConsumer ()
@property (nonatomic, readwrite) NSString *tag;
@property (nonatomic, readwrite) id<RMQChannel> channel;
@end

@implementation RMQConsumer

- (instancetype)initWithConsumerTag:(NSString *)tag
                            channel:(id<RMQChannel>)channel {
    self = [super init];
    if (self) {
        self.tag = tag;
        self.channel = channel;
    }
    return self;
}

- (void)cancel {
    [self.channel basicCancel:self.tag];
}

@end
