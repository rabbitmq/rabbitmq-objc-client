#import "RMQChannel.h"
#import "AMQDecoder.h"
#import "AMQProtocolValues.h"

@interface RMQChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (weak, nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<AMQReplyContext> replyContext;
@property (nonatomic, readwrite) RMQQueueFactory *queueFactory;
@end

@implementation RMQChannel

- (instancetype)init:(NSNumber *)channelID
           transport:(id<RMQTransport>)transport
        replyContext:(id<AMQReplyContext>)replyContext
        queueFactory:(RMQQueueFactory *)queueFactory {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.transport = transport;
        self.replyContext = replyContext;
        self.queueFactory = queueFactory;
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
    return [self.queueFactory createWithChannel:self];
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
@end
