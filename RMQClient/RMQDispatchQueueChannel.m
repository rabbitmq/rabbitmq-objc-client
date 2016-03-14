#import "RMQDispatchQueueChannel.h"
#import "AMQMethodDecoder.h"
#import "AMQValues.h"
#import "AMQMethods.h"
#import "AMQMethodMap.h"

typedef void (^Consumer)(id<RMQMessage>);

@interface RMQDispatchQueueChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, readwrite) NSMutableDictionary *consumers;
@end

@implementation RMQDispatchQueueChannel

- (instancetype)init:(NSNumber *)channelNumber sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.sender = sender;
        self.consumers = [NSMutableDictionary new];
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

- (void)basicConsume:(NSString *)queueName consumer:(Consumer)consumer {
    AMQBasicConsume *method = [[AMQBasicConsume alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                   queue:[[AMQShortstr alloc] init:queueName]
                                                             consumerTag:[[AMQShortstr alloc] init:@""]
                                                                 options:AMQBasicConsumeNoOptions
                                                               arguments:[[AMQTable alloc] init:@{}]];
    [self.sender sendMethod:method channelNumber:self.channelNumber];

    NSError *error = NULL;
    [self.sender waitOnMethod:[AMQBasicConsumeOk class] channelNumber:self.channelNumber error:&error];
    AMQBasicConsumeOk *consumeOk = (AMQBasicConsumeOk *)self.sender.lastWaitedUponFrameset.method;

    self.consumers[consumeOk.consumerTag] = consumer;
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    Class methodType = AMQMethodMap.methodMap[@[frameset.method.classID, frameset.method.methodID]];
    if (methodType == [AMQBasicDeliver class]) {
        AMQBasicDeliver *deliver = (AMQBasicDeliver *)frameset.method;
        NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
        Consumer consumer = self.consumers[deliver.consumerTag];
        RMQContentMessage *message = [[RMQContentMessage alloc] initWithConsumerTag:deliver.consumerTag.stringValue
                                                                        deliveryTag:@(deliver.deliveryTag.integerValue)
                                                                            content:content];
        consumer(message);
    }
}
@end
