#import "RMQUnallocatedChannel.h"

@interface RMQUnallocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@end

@implementation RMQUnallocatedChannel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelNumber = @(-1);
    }
    return self;
}

- (void)basicConsume:(NSString *)queueName consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {
}
- (RMQExchange *)defaultExchange {
    return nil;
}
- (RMQQueue *)queue:(NSString *)queueName autoDelete:(BOOL)shouldAutoDelete exclusive:(BOOL)isExclusive {
    return nil;
}
- (void)handleFrameset:(AMQFrameset *)frameset {

}
@end