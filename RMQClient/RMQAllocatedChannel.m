#import "AMQFrame.h"
#import "AMQMethodDecoder.h"
#import "AMQMethodMap.h"
#import "AMQMethods.h"
#import "AMQValues.h"
#import "RMQAllocatedChannel.h"

typedef void (^Consumer)(id<RMQMessage>);

@interface RMQAllocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, readwrite) NSMutableDictionary *consumers;
@property (nonatomic, readwrite) NSMutableDictionary *queues;
@property (nonatomic, readwrite) NSNumber *prefetchCount;
@property (nonatomic, readwrite) BOOL prefetchGlobal;
@end

@implementation RMQAllocatedChannel

- (instancetype)init:(NSNumber *)channelNumber sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.sender = sender;
        self.consumers = [NSMutableDictionary new];
        self.queues = [NSMutableDictionary new];
        self.prefetchCount = @0;
        self.prefetchGlobal = NO;
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
            options:(AMQQueueDeclareOptions)options {
    RMQQueue *found = self.queues[queueName];
    if (found) {
        return found;
    } else {
        AMQFrameset *frameset = [self queueDeclareFrameset:queueName
                                                   options:options];
        [self.sender sendMethod:frameset.method channelNumber:self.channelNumber];
        RMQQueue *q = [[RMQQueue alloc] initWithName:queueName
                                             options:options
                                             channel:(id<RMQChannel>)self
                                              sender:self.sender];
        self.queues[q.name] = q;
        return q;
    }
}

- (RMQQueue *)queue:(NSString *)queueName {
    return [self queue:queueName options:AMQQueueDeclareNoOptions];
}

- (AMQQueueDeclareOk *)queueDeclare:(NSString *)queueName
                            options:(AMQQueueDeclareOptions)options {
    AMQFrameset *frameset = [self queueDeclareFrameset:queueName
                                               options:options];
    NSError *error = NULL;
    AMQFrameset *incomingFrameset = [self.sender sendFrameset:frameset
                                                 waitOnMethod:[AMQQueueDeclareOk class]
                                                        error:&error];
    return (AMQQueueDeclareOk *)incomingFrameset.method;
}

- (BOOL)basicConsume:(NSString *)queueName
             options:(AMQBasicConsumeOptions)options
               error:(NSError *__autoreleasing  _Nullable * _Nullable)error
            consumer:(Consumer)consumer {
    AMQBasicConsume *method = [[AMQBasicConsume alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                   queue:[[AMQShortstr alloc] init:queueName]
                                                             consumerTag:[[AMQShortstr alloc] init:@""]
                                                                 options:options
                                                               arguments:[[AMQTable alloc] init:@{}]];
    AMQFrameset *outgoingFrameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
    AMQFrameset *frameset = [self.sender sendFrameset:outgoingFrameset
                                         waitOnMethod:[AMQBasicConsumeOk class]
                                                error:error];
    if (*error) {
        return NO;
    } else {
        AMQBasicConsumeOk *consumeOk = (AMQBasicConsumeOk *)frameset.method;
        self.consumers[consumeOk.consumerTag] = consumer;
        return YES;
    }
}

- (AMQBasicQosOk *)basicQos:(NSNumber *)count
                     global:(BOOL)isGlobal
                      error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    AMQBasicQosOptions options = AMQBasicQosNoOptions;
    if (isGlobal) options     |= AMQBasicQosGlobal;

    AMQBasicQos *qos = [[AMQBasicQos alloc] initWithPrefetchSize:[[AMQLong alloc] init:0]
                                                   prefetchCount:[[AMQShort alloc] init:count.integerValue]
                                                         options:options];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber method:qos];

    AMQBasicQosOk *response = (AMQBasicQosOk *)[self.sender sendFrameset:frameset
                                                            waitOnMethod:[AMQBasicQosOk class]
                                                                   error:error].method;
    if (response) {
        self.prefetchCount = count;
        self.prefetchGlobal = isGlobal;
        return response;
    } else {
        return nil;
    }
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    Class methodType = AMQMethodMap.methodMap[@[frameset.method.classID, frameset.method.methodID]];
    if (methodType == [AMQBasicDeliver class]) {
        AMQBasicDeliver *deliver = (AMQBasicDeliver *)frameset.method;
        NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
        Consumer consumer = self.consumers[deliver.consumerTag];
        if (consumer) {
            RMQContentMessage *message = [[RMQContentMessage alloc] initWithConsumerTag:deliver.consumerTag.stringValue
                                                                            deliveryTag:@(deliver.deliveryTag.integerValue)
                                                                                content:content];
            consumer(message);
        }
    }
}

# pragma mark - Private

- (AMQFrameset *)queueDeclareFrameset:(NSString *)queueName
                              options:(AMQQueueDeclareOptions)options {
    AMQShort *ticket          = [[AMQShort alloc] init:0];
    AMQShortstr *amqQueueName = [[AMQShortstr alloc] init:queueName];
    AMQTable *arguments       = [[AMQTable alloc] init:@{}];
    AMQQueueDeclare *method   = [[AMQQueueDeclare alloc] initWithReserved1:ticket
                                                                     queue:amqQueueName
                                                                   options:options
                                                                 arguments:arguments];
    return [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                               method:method];
}

@end
