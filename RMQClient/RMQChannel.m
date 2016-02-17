#import "RMQChannel.h"
#import "AMQDecoder.h"
#import "RMQQueue.h"
#import "AMQProtocolValues.h"

@interface RMQChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (weak, nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<AMQReplyContext> replyContext;
@end

@implementation RMQChannel

- (instancetype)init:(NSNumber *)channelID
           transport:(id<RMQTransport>)transport
        replyContext:(id<AMQReplyContext>)replyContext {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.transport = transport;
        self.replyContext = replyContext;
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
    return [[RMQQueue alloc] initWithChannel:self];
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
@end
