#import "RMQBasicProperties.h"
#import "RMQConstants.h"
#import "RMQFrame.h"
#import "RMQMethodDecoder.h"
#import "RMQMethodMap.h"
#import "RMQMethods.h"
#import "RMQAllocatedChannel.h"
#import "RMQConnectionDelegate.h"
#import "RMQDeliveryInfo.h"

@interface RMQAllocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, readwrite) NSMutableDictionary *consumers;
@property (nonatomic, readwrite) NSMutableDictionary *exchanges;
@property (nonatomic, readwrite) NSMutableDictionary *queues;
@property (nonatomic, readwrite) NSNumber *prefetchCount;
@property (nonatomic, readwrite) BOOL prefetchGlobal;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) id<RMQFramesetWaiter> waiter;
@property (nonatomic, readwrite) id<RMQNameGenerator> nameGenerator;
@end

@implementation RMQAllocatedChannel

- (instancetype)init:(NSNumber *)channelNumber
              sender:(id<RMQSender>)sender
              waiter:(id<RMQFramesetWaiter>)waiter
        commandQueue:(id<RMQLocalSerialQueue>)commandQueue
       nameGenerator:(id<RMQNameGenerator>)nameGenerator {
    self = [super init];
    if (self) {
        self.commandQueue = commandQueue;
        self.active = NO;
        self.channelNumber = channelNumber;
        self.sender = sender;
        self.consumers = [NSMutableDictionary new];
        self.exchanges = [NSMutableDictionary new];
        self.queues = [NSMutableDictionary new];
        self.prefetchCount = @0;
        self.prefetchGlobal = NO;
        self.delegate = nil;
        self.waiter = waiter;
        self.nameGenerator = nameGenerator;
    }
    return self;
}

- (instancetype)init:(NSNumber *)channelNumber
              sender:(id<RMQSender>)sender
              waiter:(id<RMQFramesetWaiter>)waiter
        commandQueue:(id<RMQLocalSerialQueue>)commandQueue {
    return [self init:channelNumber
               sender:sender
               waiter:waiter
         commandQueue:commandQueue
        nameGenerator:nil];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    if (!self.active) {
        [self.commandQueue resume];
    }
}

- (RMQExchange *)defaultExchange {
    return [[RMQExchange alloc] initWithName:@"" channel:self];
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
    [self.commandQueue resume];
    self.active = YES;
}

- (void)open {
    RMQChannelOpen *outgoingMethod = [[RMQChannelOpen alloc] initWithReserved1:[[RMQShortstr alloc] init:@""]];
    RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:outgoingMethod];

    [self.commandQueue enqueue:^{
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

    [self.commandQueue blockingEnqueue:^{
        [self.sender sendFrameset:frameset];

        RMQFramesetWaitResult *result = [self.waiter waitOn:[RMQChannelCloseOk class]];
        if (result.error) {
            [self.delegate channel:self error:result.error];
        }
    }];

}

- (RMQQueue *)queue:(NSString *)originalQueueName
            options:(RMQQueueDeclareOptions)options {
    RMQQueue *found = self.queues[originalQueueName];
    if (found) {
        return found;
    } else {
        return [self memoizedQueueDeclare:originalQueueName options:options];
    }
}

- (RMQQueue *)queue:(NSString *)queueName {
    return [self queue:queueName options:RMQQueueDeclareNoOptions];
}

- (void)queueBind:(NSString *)queueName
         exchange:(NSString *)exchangeName
       routingKey:(nonnull NSString *)routingKey {
    [self sendAsyncMethod:[[RMQQueueBind alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                            queue:[[RMQShortstr alloc] init:queueName]
                                                         exchange:[[RMQShortstr alloc] init:exchangeName]
                                                       routingKey:[[RMQShortstr alloc] init:routingKey]
                                                          options:RMQQueueBindNoOptions
                                                        arguments:[[RMQTable alloc] init:@{}]]
                   waitOn:[RMQQueueBindOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
        }];
}

- (void)queueUnbind:(NSString *)queueName
           exchange:(NSString *)exchangeName
         routingKey:(NSString *)routingKey {
    [self sendAsyncMethod:[[RMQQueueUnbind alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                              queue:[[RMQShortstr alloc] init:queueName]
                                                           exchange:[[RMQShortstr alloc] init:exchangeName]
                                                         routingKey:[[RMQShortstr alloc] init:routingKey]
                                                          arguments:[[RMQTable alloc] init:@{}]]
                   waitOn:[RMQQueueUnbindOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
        }];
}

- (void)basicConsume:(NSString *)queueName
             options:(RMQBasicConsumeOptions)options
            consumer:(RMQConsumer)consumer {
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
            exchange:(NSString *)exchange
          persistent:(BOOL)isPersistent {
    RMQBasicPublish *publish = [[RMQBasicPublish alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                                 exchange:[[RMQShortstr alloc] init:exchange]
                                                               routingKey:[[RMQShortstr alloc] init:routingKey]
                                                                  options:RMQBasicPublishNoOptions];
    NSData *contentBodyData = [message dataUsingEncoding:NSUTF8StringEncoding];
    RMQContentBody *contentBody = [[RMQContentBody alloc] initWithData:contentBodyData];

    RMQBasicDeliveryMode *mode;
    if (isPersistent) {
        mode = [[RMQBasicDeliveryMode alloc] init:2];
    } else {
        mode = [[RMQBasicDeliveryMode alloc] init:1];
    }
    RMQBasicContentType *octetStream = [[RMQBasicContentType alloc] init:@"application/octet-stream"];
    RMQBasicPriority *lowPriority = [[RMQBasicPriority alloc] init:0];

    NSData *bodyData = contentBody.amqEncoded;
    RMQContentHeader *contentHeader = [[RMQContentHeader alloc] initWithClassID:publish.classID
                                                                       bodySize:@(bodyData.length)
                                                                     properties:@[mode, octetStream, lowPriority]];

    NSArray *contentBodies = [self contentBodiesFromData:bodyData
                                              inChunksOf:self.sender.frameMax.integerValue - RMQEmptyFrameSize];
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                method:publish
                                                         contentHeader:contentHeader
                                                         contentBodies:contentBodies];

    [self.commandQueue enqueue:^{
        [self.sender sendFrameset:frameset];
    }];
}

-  (void)basicGet:(NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumer)userCompletionHandler {
    [self sendAsyncMethod:[[RMQBasicGet alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                           queue:[[RMQShortstr alloc] init:queue]
                                                         options:options]
                   waitOn:[RMQBasicGetOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
            RMQFrameset *getOkFrameset = result.frameset;
            RMQBasicGetOk *getOk = (RMQBasicGetOk *)getOkFrameset.method;
            NSString *messageContent = [[NSString alloc] initWithData:getOkFrameset.contentData
                                                             encoding:NSUTF8StringEncoding];
            RMQMessage *message = [[RMQMessage alloc] initWithConsumerTag:@""
                                                              deliveryTag:@(getOk.deliveryTag.integerValue)
                                                                  content:messageContent];
            RMQDeliveryInfo *deliveryInfo = [[RMQDeliveryInfo alloc] initWithRoutingKey:getOk.routingKey.stringValue];
            userCompletionHandler(deliveryInfo, message);
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

- (void)exchangeDeclare:(NSString *)name
                   type:(NSString *)type
                options:(RMQExchangeDeclareOptions)options {
    [self sendAsyncMethod:[[RMQExchangeDeclare alloc] initWithReserved1:[[RMQShort alloc] init:0]
                                                               exchange:[[RMQShortstr alloc] init:name]
                                                                   type:[[RMQShortstr alloc] init:type]
                                                                options:options
                                                              arguments:[[RMQTable alloc] init:@{}]]
                   waitOn:[RMQExchangeDeclareOk class]
        completionHandler:^(RMQFramesetWaitResult *result) {
        }];
}

- (RMQExchange *)fanout:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    return [self memoizedExchangeDeclare:name type:@"fanout" options:options];
}

- (RMQExchange *)fanout:(NSString *)name {
    return [self fanout:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)direct:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    return [self memoizedExchangeDeclare:name type:@"direct" options:options];
}

- (RMQExchange *)direct:(NSString *)name {
    return [self direct:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)topic:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    return [self memoizedExchangeDeclare:name type:@"topic" options:options];
}

- (RMQExchange *)topic:(NSString *)name {
    return [self topic:name options:RMQExchangeDeclareNoOptions];
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(RMQFrameset *)frameset {
    if ([frameset.method isKindOfClass:[RMQBasicDeliver class]]) {
        [self.commandQueue enqueue:^{
            RMQBasicDeliver *deliver = (RMQBasicDeliver *)frameset.method;
            NSString *content = [[NSString alloc] initWithData:frameset.contentData encoding:NSUTF8StringEncoding];
            RMQConsumer consumer = self.consumers[deliver.consumerTag];
            if (consumer) {
                RMQMessage *message = [[RMQMessage alloc] initWithConsumerTag:deliver.consumerTag.stringValue
                                                                  deliveryTag:@(deliver.deliveryTag.integerValue)
                                                                      content:content];
                RMQDeliveryInfo *deliveryInfo = [[RMQDeliveryInfo alloc] initWithRoutingKey:deliver.routingKey.stringValue];
                consumer(deliveryInfo, message);
            }
        }];
    } else {
        [self.waiter fulfill:frameset];
    }
}

# pragma mark - Private

- (RMQExchange *)memoizedExchangeDeclare:(NSString *)name
                                    type:(NSString *)type
                                 options:(RMQExchangeDeclareOptions)options {
    RMQExchange *exchange;
    exchange = self.exchanges[name];
    if (!exchange) {
        [self exchangeDeclare:name type:type options:options];
        exchange = [[RMQExchange alloc] initWithName:name channel:self];
        self.exchanges[name] = exchange;
    }
    return exchange;
}

- (RMQQueue *)memoizedQueueDeclare:(NSString *)originalQueueName options:(RMQQueueDeclareOptions)options {
    NSString *declaredQueueName = [originalQueueName isEqualToString:@""]
    ? [self.nameGenerator generateWithPrefix:@"rmq-objc-client.gen-"]
    : originalQueueName;

    if (self.queues[declaredQueueName]) {
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQChannelErrorQueueNameCollision
                                         userInfo:@{NSLocalizedDescriptionKey: @"Name collision when generating unique name."}];
        [self.delegate channel:self error:error];
        return nil;
    } else {
        [self sendAsyncMethod:[self queueDeclareMethod:declaredQueueName options:options]
                       waitOn:[RMQQueueDeclareOk class]
            completionHandler:^(RMQFramesetWaitResult *result) {
            }];

        RMQQueue *q = [[RMQQueue alloc] initWithName:declaredQueueName
                                             options:options
                                             channel:(id<RMQChannel>)self
                                              sender:self.sender];
        self.queues[q.name] = q;
        return q;
    }
}

- (RMQQueueDeclare *)queueDeclareMethod:(NSString *)declaredQueueName options:(RMQQueueDeclareOptions)options {
    RMQShort *ticket          = [[RMQShort alloc] init:0];
    RMQShortstr *amqQueueName = [[RMQShortstr alloc] init:declaredQueueName];
    RMQTable *arguments       = [[RMQTable alloc] init:@{}];
    return [[RMQQueueDeclare alloc] initWithReserved1:ticket
                                                queue:amqQueueName
                                              options:options
                                            arguments:arguments];
}

- (void)sendAsyncMethod:(id<RMQMethod>)method {
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];

    [self.commandQueue enqueue:^{
        [self.sender sendFrameset:frameset];
    }];
}

- (void)sendAsyncMethod:(id<RMQMethod>)method
                 waitOn:(Class)waitClass
      completionHandler:(void (^)(RMQFramesetWaitResult *result))completionHandler {
    RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
    [self.commandQueue enqueue:^{
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
