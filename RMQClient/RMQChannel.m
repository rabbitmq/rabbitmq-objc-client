#import "RMQChannel.h"

@interface RMQChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@end

@implementation RMQChannel

- (instancetype)init:(NSNumber *)channelID {
    self = [super init];
    if (self) {
        self.channelID = channelID;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive {
    return [RMQQueue new];
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}

@end
