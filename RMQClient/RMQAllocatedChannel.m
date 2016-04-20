#import "AMQBasicProperties.h"
#import "AMQConstants.h"
#import "AMQFrame.h"
#import "AMQMethodDecoder.h"
#import "AMQMethodMap.h"
#import "AMQMethods.h"
#import "RMQAllocatedChannel.h"
#import "RMQConnectionDelegate.h"

typedef void (^Consumer)(id<RMQMessage>);

@interface RMQAllocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, readwrite) NSMutableDictionary *consumers;
@property (nonatomic, readwrite) NSMutableDictionary *queues;
@property (nonatomic, readwrite) NSNumber *prefetchCount;
@property (nonatomic, readwrite) BOOL prefetchGlobal;
@property (nonatomic, readwrite) dispatch_queue_t queue;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) id<RMQFramesetWaiter> waiter;
@end

@implementation RMQAllocatedChannel

- (instancetype)init:(NSNumber *)channelNumber
              sender:(id<RMQSender>)sender
              waiter:(id<RMQFramesetWaiter>)waiter
               queue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.active = NO;
        self.channelNumber = channelNumber;
        self.sender = sender;
        self.consumers = [NSMutableDictionary new];
        self.queues = [NSMutableDictionary new];
        self.prefetchCount = @0;
        self.prefetchGlobal = NO;
        self.delegate = nil;
        self.waiter = waiter;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    if (!self.active) {
        dispatch_resume(self.queue);
    }
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
    dispatch_resume(self.queue);
    self.active = YES;
}

- (void)open {
    AMQChannelOpen *outgoingMethod = [[AMQChannelOpen alloc] initWithReserved1:[[AMQShortstr alloc] init:@""]];
    AMQFrameset *outgoingFrameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber method:outgoingMethod];

    dispatch_async(self.queue, ^{
        [self.sender sendFrameset:outgoingFrameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:[AMQChannelOpenOk class]];
        if (result.error) {
            [self.delegate connection:(RMQConnection *)self.sender failedToOpenChannel:self error:result.error];
        }
    });
}

- (RMQQueue *)queue:(NSString *)queueName
            options:(AMQQueueDeclareOptions)options {
    RMQQueue *found = self.queues[queueName];
    if (found) {
        return found;
    } else {
        AMQShort *ticket                     = [[AMQShort alloc] init:0];
        AMQShortstr *amqQueueName            = [[AMQShortstr alloc] init:queueName];
        AMQTable *arguments                  = [[AMQTable alloc] init:@{}];
        AMQQueueDeclareOptions mergedOptions = options | AMQQueueDeclareNoWait;
        AMQQueueDeclare *method              = [[AMQQueueDeclare alloc] initWithReserved1:ticket
                                                                                    queue:amqQueueName
                                                                                  options:mergedOptions
                                                                                arguments:arguments];
        [self sendAsyncMethod:method];

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

- (void)basicConsume:(NSString *)queueName
             options:(AMQBasicConsumeOptions)options
            consumer:(Consumer)consumer {
    [self sendAsyncMethod:[[AMQBasicConsume alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                               queue:[[AMQShortstr alloc] init:queueName]
                                                         consumerTag:[[AMQShortstr alloc] init:@""]
                                                             options:options
                                                           arguments:[[AMQTable alloc] init:@{}]]
                   waitOn:[AMQBasicConsumeOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
            AMQBasicConsumeOk *consumeOk = (AMQBasicConsumeOk *)result.frameset.method;
            self.consumers[consumeOk.consumerTag] = consumer;
        }];
}

- (void)basicPublish:(NSString *)message
          routingKey:(NSString *)routingKey
            exchange:(NSString *)exchange {
    AMQBasicPublish *publish = [[AMQBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                 exchange:[[AMQShortstr alloc] init:exchange]
                                                               routingKey:[[AMQShortstr alloc] init:routingKey]
                                                                  options:AMQBasicPublishNoOptions];
    NSData *contentBodyData = [message dataUsingEncoding:NSUTF8StringEncoding];
    AMQContentBody *contentBody = [[AMQContentBody alloc] initWithData:contentBodyData];

    AMQBasicDeliveryMode *persistent = [[AMQBasicDeliveryMode alloc] init:2];
    AMQBasicContentType *octetStream = [[AMQBasicContentType alloc] init:@"application/octet-stream"];
    AMQBasicPriority *lowPriority = [[AMQBasicPriority alloc] init:0];

    NSData *bodyData = contentBody.amqEncoded;
    AMQContentHeader *contentHeader = [[AMQContentHeader alloc] initWithClassID:publish.classID
                                                                       bodySize:@(bodyData.length)
                                                                     properties:@[persistent, octetStream, lowPriority]];

    NSArray *contentBodies = [self contentBodiesFromData:bodyData
                                              inChunksOf:self.sender.frameMax.integerValue - AMQEmptyFrameSize];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                method:publish
                                                         contentHeader:contentHeader
                                                         contentBodies:contentBodies];

    dispatch_async(self.queue, ^{
        [self.sender sendFrameset:frameset];
    });
}

-  (void)basicGet:(NSString *)queue
          options:(AMQBasicGetOptions)options
completionHandler:(void (^)(id<RMQMessage> _Nonnull))userCompletionHandler {
    [self sendAsyncMethod:[[AMQBasicGet alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                           queue:[[AMQShortstr alloc] init:queue]
                                                         options:options]
                   waitOn:[AMQBasicGetOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
            AMQFrameset *getOkFrameset = result.frameset;
            AMQBasicGetOk *getOk = (AMQBasicGetOk *)getOkFrameset.method;
            NSString *messageContent = [[NSString alloc] initWithData:getOkFrameset.contentData
                                                             encoding:NSUTF8StringEncoding];
            RMQContentMessage *message = [[RMQContentMessage alloc] initWithConsumerTag:@""
                                                                            deliveryTag:@(getOk.deliveryTag.integerValue)
                                                                                content:messageContent];
            userCompletionHandler(message);
        }];
}

- (void)basicQos:(NSNumber *)count
          global:(BOOL)isGlobal {
    AMQBasicQosOptions options = AMQBasicQosNoOptions;
    if (isGlobal) options     |= AMQBasicQosGlobal;

    [self sendAsyncMethod:[[AMQBasicQos alloc] initWithPrefetchSize:[[AMQLong alloc] init:0]
                                                      prefetchCount:[[AMQShort alloc] init:count.integerValue]
                                                            options:options]
                   waitOn:[AMQBasicQosOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {}];
}

- (void)ack:(NSNumber *)deliveryTag
    options:(AMQBasicAckOptions)options {
    [self sendAsyncMethod:[[AMQBasicAck alloc] initWithDeliveryTag:[[AMQLonglong alloc] init:deliveryTag.integerValue]
                                                           options:options]];
}

- (void)ack:(NSNumber *)deliveryTag {
    [self ack:deliveryTag options:AMQBasicAckNoOptions];
}

- (void)reject:(NSNumber *)deliveryTag
       options:(AMQBasicRejectOptions)options {
    [self sendAsyncMethod:[[AMQBasicReject alloc] initWithDeliveryTag:[[AMQLonglong alloc] init:deliveryTag.integerValue]
                                                              options:options]];
}

- (void)reject:(NSNumber *)deliveryTag {
    [self reject:deliveryTag options:AMQBasicRejectNoOptions];
}

- (void)nack:(NSNumber *)deliveryTag
     options:(AMQBasicNackOptions)options {
    [self sendAsyncMethod:[[AMQBasicNack alloc] initWithDeliveryTag:[[AMQLonglong alloc] init:deliveryTag.integerValue]
                                                            options:options]];
}

- (void)nack:(NSNumber *)deliveryTag {
    [self nack:deliveryTag options:AMQBasicNackNoOptions];
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(AMQFrameset *)frameset {
    if ([frameset.method isKindOfClass:[AMQBasicDeliver class]]) {
        dispatch_async(self.queue, ^{
            AMQBasicDeliver *deliver = (AMQBasicDeliver *)frameset.method;
            NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
            Consumer consumer = self.consumers[deliver.consumerTag];
            if (consumer) {
                RMQContentMessage *message = [[RMQContentMessage alloc] initWithConsumerTag:deliver.consumerTag.stringValue
                                                                                deliveryTag:@(deliver.deliveryTag.integerValue)
                                                                                    content:content];
                consumer(message);
            }
        });
    } else {
        [self.waiter fulfill:frameset];
    }
}

# pragma mark - Private

- (void)sendAsyncMethod:(id<AMQMethod>)method {
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];

    dispatch_async(self.queue, ^{
        [self.sender sendFrameset:frameset];
    });
}

- (void)sendAsyncMethod:(id<AMQMethod>)method
                 waitOn:(Class)waitClass
      completionHandler:(void (^)(RMQFramesetWaitResult *result))completionHandler {
    AMQFrameset *outgoingFrameset = [[AMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
    dispatch_async(self.queue, ^{
        [self.sender sendFrameset:outgoingFrameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:waitClass];
        if (result.error) {
            [self.delegate channel:self error:result.error];
        } else {
            completionHandler(result);
        }
    });
}

- (NSArray *)contentBodiesFromData:(NSData *)data inChunksOf:(NSUInteger)chunkSize {
    NSMutableArray *bodies = [NSMutableArray new];
    NSUInteger chunkCount = data.length / chunkSize;
    for (int i = 0; i < chunkCount; i++) {
        NSUInteger offset = i * chunkSize;
        NSData *subData = [data subdataWithRange:NSMakeRange(offset, chunkSize)];
        AMQContentBody *body = [[AMQContentBody alloc] initWithData:subData];
        [bodies addObject:body];
    }
    NSUInteger lastChunkSize = data.length % chunkSize;
    if (lastChunkSize > 0) {
        NSData *lastData = [data subdataWithRange:NSMakeRange(data.length - lastChunkSize, lastChunkSize)];
        [bodies addObject:[[AMQContentBody alloc] initWithData:lastData]];
    }
    return bodies;
}

@end
