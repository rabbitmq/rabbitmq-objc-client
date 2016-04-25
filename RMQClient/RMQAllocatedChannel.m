#import "RMQBasicProperties.h"
#import "RMQConstants.h"
#import "RMQFrame.h"
#import "RMQMethodDecoder.h"
#import "RMQMethodMap.h"
#import "RMQMethods.h"
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
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> queue;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) id<RMQFramesetWaiter> waiter;
@end

@implementation RMQAllocatedChannel

- (instancetype)init:(NSNumber *)channelNumber
              sender:(id<RMQSender>)sender
              waiter:(id<RMQFramesetWaiter>)waiter
               queue:(id<RMQLocalSerialQueue>)queue {
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
        [self.queue resume];
    }
}

- (RMQExchange *)defaultExchange {
    return [[RMQExchange alloc] initWithChannel:self];
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
    [self.queue resume];
    self.active = YES;
}

- (void)open {
    RMQChannelOpen *outgoingMethod = [[RMQChannelOpen alloc] initWithReserved1:[[RMQShortstr alloc] init:@""]];
    RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:outgoingMethod];

    [self.queue enqueue:^{
        [self.sender sendFrameset:outgoingFrameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:[RMQChannelOpenOk class]];
        if (result.error) {
            [self.delegate connection:(RMQConnection *)self.sender failedToOpenChannel:self error:result.error];
        }
    }];
}

- (void)blockingClose {
    RMQChannelClose *close = [[RMQChannelClose alloc] initWithReplyCode:[[RMQShort alloc] init:200]
                                                              replyText:[[RMQShortstr alloc] init:@"Goodbye"]
                                                                classId:[[RMQShort alloc] init:0]
                                                               methodId:[[RMQShort alloc] init:0]];
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:close];

    [self.queue blockingEnqueue:^{
        [self.sender sendFrameset:frameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:[RMQChannelCloseOk class]];
        if (result.error) {
            [self.delegate channel:self error:result.error];
        }
    }];

}

- (RMQQueue *)queue:(NSString *)queueName
            options:(RMQQueueDeclareOptions)options {
    RMQQueue *found = self.queues[queueName];
    if (found) {
        return found;
    } else {
        RMQShort *ticket                     = [[RMQShort alloc] init:0];
        RMQShortstr *amqQueueName            = [[RMQShortstr alloc] init:queueName];
        RMQTable *arguments                  = [[RMQTable alloc] init:@{}];
        RMQQueueDeclareOptions mergedOptions = options | RMQQueueDeclareNoWait;
        RMQQueueDeclare *method              = [[RMQQueueDeclare alloc] initWithReserved1:ticket
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
    return [self queue:queueName options:RMQQueueDeclareNoOptions];
}

- (void)basicConsume:(NSString *)queueName
             options:(RMQBasicConsumeOptions)options
            consumer:(Consumer)consumer {
    [self sendAsyncMethod:[[RMQBasicConsume alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                               queue:[[RMQShortstr alloc] init:queueName]
                                                         consumerTag:[[RMQShortstr alloc] init:@""]
                                                             options:options
                                                           arguments:[[RMQTable alloc] init:@{}]]
                   waitOn:[RMQBasicConsumeOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
            RMQBasicConsumeOk *consumeOk = (RMQBasicConsumeOk *)result.frameset.method;
            self.consumers[consumeOk.consumerTag] = consumer;
        }];
}

- (void)basicPublish:(NSString *)message
          routingKey:(NSString *)routingKey
            exchange:(NSString *)exchange {
    RMQBasicPublish *publish = [[RMQBasicPublish alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                                 exchange:[[RMQShortstr alloc] init:exchange]
                                                               routingKey:[[RMQShortstr alloc] init:routingKey]
                                                                  options:RMQBasicPublishNoOptions];
    NSData *contentBodyData = [message dataUsingEncoding:NSUTF8StringEncoding];
    RMQContentBody *contentBody = [[RMQContentBody alloc] initWithData:contentBodyData];

    RMQBasicDeliveryMode *persistent = [[RMQBasicDeliveryMode alloc] init:2];
    RMQBasicContentType *octetStream = [[RMQBasicContentType alloc] init:@"application/octet-stream"];
    RMQBasicPriority *lowPriority = [[RMQBasicPriority alloc] init:0];

    NSData *bodyData = contentBody.amqEncoded;
    RMQContentHeader *contentHeader = [[RMQContentHeader alloc] initWithClassID:publish.classID
                                                                       bodySize:@(bodyData.length)
                                                                     properties:@[persistent, octetStream, lowPriority]];

    NSArray *contentBodies = [self contentBodiesFromData:bodyData
                                              inChunksOf:self.sender.frameMax.integerValue - RMQEmptyFrameSize];
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                method:publish
                                                         contentHeader:contentHeader
                                                         contentBodies:contentBodies];

    [self.queue enqueue:^{
        [self.sender sendFrameset:frameset];
    }];
}

-  (void)basicGet:(NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(void (^)(id<RMQMessage> _Nonnull))userCompletionHandler {
    [self sendAsyncMethod:[[RMQBasicGet alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                           queue:[[RMQShortstr alloc] init:queue]
                                                         options:options]
                   waitOn:[RMQBasicGetOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
            RMQFrameset *getOkFrameset = result.frameset;
            RMQBasicGetOk *getOk = (RMQBasicGetOk *)getOkFrameset.method;
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
    RMQBasicQosOptions options = RMQBasicQosNoOptions;
    if (isGlobal) options     |= RMQBasicQosGlobal;

    [self sendAsyncMethod:[[RMQBasicQos alloc] initWithPrefetchSize:[[RMQLong alloc] init:0]
                                                      prefetchCount:[[RMQShort alloc] init:count.integerValue]
                                                            options:options]
                   waitOn:[RMQBasicQosOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {}];
}

- (void)ack:(NSNumber *)deliveryTag
    options:(RMQBasicAckOptions)options {
    [self sendAsyncMethod:[[RMQBasicAck alloc] initWithDeliveryTag:[[RMQLonglong alloc] init:deliveryTag.integerValue]
                                                           options:options]];
}

- (void)ack:(NSNumber *)deliveryTag {
    [self ack:deliveryTag options:RMQBasicAckNoOptions];
}

- (void)reject:(NSNumber *)deliveryTag
       options:(RMQBasicRejectOptions)options {
    [self sendAsyncMethod:[[RMQBasicReject alloc] initWithDeliveryTag:[[RMQLonglong alloc] init:deliveryTag.integerValue]
                                                              options:options]];
}

- (void)reject:(NSNumber *)deliveryTag {
    [self reject:deliveryTag options:RMQBasicRejectNoOptions];
}

- (void)nack:(NSNumber *)deliveryTag
     options:(RMQBasicNackOptions)options {
    [self sendAsyncMethod:[[RMQBasicNack alloc] initWithDeliveryTag:[[RMQLonglong alloc] init:deliveryTag.integerValue]
                                                            options:options]];
}

- (void)nack:(NSNumber *)deliveryTag {
    [self nack:deliveryTag options:RMQBasicNackNoOptions];
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(RMQFrameset *)frameset {
    if ([frameset.method isKindOfClass:[RMQBasicDeliver class]]) {
        [self.queue enqueue:^{
            RMQBasicDeliver *deliver = (RMQBasicDeliver *)frameset.method;
            NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
            Consumer consumer = self.consumers[deliver.consumerTag];
            if (consumer) {
                RMQContentMessage *message = [[RMQContentMessage alloc] initWithConsumerTag:deliver.consumerTag.stringValue
                                                                                deliveryTag:@(deliver.deliveryTag.integerValue)
                                                                                    content:content];
                consumer(message);
            }
        }];
    } else {
        [self.waiter fulfill:frameset];
    }
}

# pragma mark - Private

- (void)sendAsyncMethod:(id<RMQMethod>)method {
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];

    [self.queue enqueue:^{
        [self.sender sendFrameset:frameset];
    }];
}

- (void)sendAsyncMethod:(id<RMQMethod>)method
                 waitOn:(Class)waitClass
      completionHandler:(void (^)(RMQFramesetWaitResult *result))completionHandler {
    RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
    [self.queue enqueue:^{
        [self.sender sendFrameset:outgoingFrameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:waitClass];
        if (result.error) {
            [self.delegate channel:self error:result.error];
        } else {
            completionHandler(result);
        }
    }];
}

- (NSArray *)contentBodiesFromData:(NSData *)data inChunksOf:(NSUInteger)chunkSize {
    NSMutableArray *bodies = [NSMutableArray new];
    NSUInteger chunkCount = data.length / chunkSize;
    for (int i = 0; i < chunkCount; i++) {
        NSUInteger offset = i * chunkSize;
        NSData *subData = [data subdataWithRange:NSMakeRange(offset, chunkSize)];
        RMQContentBody *body = [[RMQContentBody alloc] initWithData:subData];
        [bodies addObject:body];
    }
    NSUInteger lastChunkSize = data.length % chunkSize;
    if (lastChunkSize > 0) {
        NSData *lastData = [data subdataWithRange:NSMakeRange(data.length - lastChunkSize, lastChunkSize)];
        [bodies addObject:[[RMQContentBody alloc] initWithData:lastData]];
    }
    return bodies;
}

@end
