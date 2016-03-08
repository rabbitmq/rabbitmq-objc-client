#import "RMQDispatchQueueChannel.h"
#import "AMQMethodDecoder.h"
#import "AMQValues.h"
#import "AMQMethods.h"

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

    AMQQueueDeclareOptions options = AMQQueueDeclareDurable;
    if (isExclusive)            { options |= AMQQueueDeclareExclusive; }
    if (shouldAutoDelete)       { options |= AMQQueueDeclareAutoDelete; }

    AMQQueueDeclare *method = [[AMQQueueDeclare alloc] initWithReserved1:ticket
                                                                                   queue:amqQueueName
                                                                                 options:options
                                                                               arguments:arguments];
    [self.sender sendMethod:method channelNumber:self.channelNumber];
    return [[RMQQueue alloc] initWithName:queueName
                                  channel:(id <RMQChannel>)self
                                   sender:self.sender];
}

- (void)basicConsume:(NSString *)queueName consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {
    AMQBasicConsume *method = [[AMQBasicConsume alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                                   queue:[[AMQShortstr alloc] init:queueName]
                                                                             consumerTag:[[AMQShortstr alloc] init:@""]
                                                                                 options:AMQBasicConsumeNoOptions
                                                                               arguments:[[AMQTable alloc] init:@{}]];
    [self.sender sendMethod:method channelNumber:self.channelNumber];

    NSError *error = NULL;
    [self.sender waitOnMethod:[AMQBasicConsumeOk class] channelNumber:self.channelNumber error:&error];
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
