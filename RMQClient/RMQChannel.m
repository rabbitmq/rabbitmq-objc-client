#import "RMQChannel.h"
#import "AMQMethodDecoder.h"
#import "AMQProtocolValues.h"
#import "AMQProtocolMethods.h"

@interface RMQChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (nonatomic, readwrite) id <RMQSender> sender;
@end

@implementation RMQChannel

- (instancetype)init:(NSNumber *)channelID sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.sender = sender;
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
    AMQShort *ticket          = [[AMQShort alloc] init:0];
    AMQShortstr *amqQueueName = [[AMQShortstr alloc] init:queueName];
    AMQTable *arguments       = [[AMQTable alloc] init:@{}];

    AMQProtocolQueueDeclareOptions options = AMQProtocolQueueDeclareDurable;
    if (isExclusive)            { options |= AMQProtocolQueueDeclareExclusive; }
    if (shouldAutoDelete)       { options |= AMQProtocolQueueDeclareAutoDelete; }

    AMQProtocolQueueDeclare *method = [[AMQProtocolQueueDeclare alloc] initWithReserved1:ticket
                                                                                   queue:amqQueueName
                                                                                 options:options
                                                                               arguments:arguments];
    [self.sender sendMethod:method channelID:self.channelID];
    return [[RMQQueue alloc] initWithName:queueName channel:self sender:self.sender];
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
@end
