#import "RMQDispatchQueueChannel.h"
#import "AMQMethodDecoder.h"
#import "AMQProtocolValues.h"
#import "AMQProtocolMethods.h"

@interface RMQDispatchQueueChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, copy, readwrite) void (^lastConsumer)(id<RMQMessage>);
@end

@implementation RMQDispatchQueueChannel

- (instancetype)init:(NSNumber *)channelNumber sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.sender = sender;
        self.lastConsumer = ^(id<RMQMessage> m){};
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
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
    [self.sender sendMethod:method channelNumber:self.channelNumber];
    return [[RMQQueue alloc] initWithName:queueName
                                  channel:(id <RMQChannel>)self
                                   sender:self.sender];
}

- (void)basicConsume:(NSString *)queueName consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {
    AMQProtocolBasicConsume *method = [[AMQProtocolBasicConsume alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                                   queue:[[AMQShortstr alloc] init:queueName]
                                                                             consumerTag:[[AMQShortstr alloc] init:@""]
                                                                                 options:AMQProtocolBasicConsumeNoOptions
                                                                               arguments:[[AMQTable alloc] init:@{}]];
    [self.sender sendMethod:method channelNumber:self.channelNumber];

    NSError *error = NULL;
    [self.sender waitOnMethod:[AMQProtocolBasicConsumeOk class] channelNumber:self.channelNumber error:&error];
    self.lastConsumer = consumer;
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
    RMQContentMessage *message = [[RMQContentMessage alloc] initWithDeliveryInfo:@{@"consumer_tag" : @"foo"}
                                                                        metadata:@{@"foo" : @"bar"}
                                                                         content:content];
    self.lastConsumer(message);
}
@end
