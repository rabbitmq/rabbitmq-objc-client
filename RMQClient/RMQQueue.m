#import "RMQQueue.h"
#import "AMQMethods.h"
#import "RMQConnection.h"
#import "AMQBasicProperties.h"
#import "AMQConstants.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) AMQQueueDeclareOptions options;
@property (nonatomic, readwrite) id <RMQChannel> channel;
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     options:(AMQQueueDeclareOptions)options
                     channel:(id<RMQChannel>)channel
                      sender:(id<RMQSender>)sender {
   self = [super init];
    if (self) {
        self.name = name;
        self.options = options;
        self.channel = channel;
        self.sender = sender;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                     channel:(id<RMQChannel>)channel
                      sender:(id<RMQSender>)sender {
    return [self initWithName:name options:AMQQueueDeclareNoOptions channel:channel sender:sender];
}

- (RMQQueue *)publish:(NSString *)message {
    AMQBasicPublish *publish = [[AMQBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                 exchange:[[AMQShortstr alloc] init:@""]
                                                               routingKey:[[AMQShortstr alloc] init:self.name]
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
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:self.channel.channelNumber
                                                                method:publish
                                                         contentHeader:contentHeader
                                                         contentBodies:contentBodies];
    [self.sender sendFrameset:frameset];
    return self;
}

- (id<RMQMessage>)pop {
    AMQBasicGet *get = [[AMQBasicGet alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                        queue:[[AMQShortstr alloc] init:self.name]
                                                      options:AMQBasicGetNoOptions];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:self.channel.channelNumber
                                                                method:get
                                                         contentHeader:[AMQContentHeaderNone new]
                                                         contentBodies:@[]];
    NSError *error = NULL;
    AMQFrameset *getOkFrameset = [self.sender sendFrameset:frameset
                                              waitOnMethod:[AMQBasicGetOk class]
                                                     error:&error];
    if (error) {
        NSLog(@"\n**** ERROR WAITING FOR GET-OK %@", error);
    }

    NSString *content = [[NSString alloc] initWithData:getOkFrameset.contentData
                                              encoding:NSUTF8StringEncoding];

    AMQBasicGetOk *getOk = (AMQBasicGetOk *)getOkFrameset.method;

    return [[RMQContentMessage alloc] initWithConsumerTag:@""
                                              deliveryTag:@(getOk.deliveryTag.integerValue)
                                                  content:content];
}

- (void)subscribe:(void (^)(id<RMQMessage> _Nonnull))handler {
    [self.channel basicConsume:self.name consumer:handler];
}

- (NSNumber *)messageCount {
    return @(self.redeclare.messageCount.integerValue);
}

- (NSNumber *)consumerCount {
    return @(self.redeclare.consumerCount.integerValue);
}

# pragma mark - Private

- (AMQQueueDeclareOk *)redeclare {
    return [self.channel queueDeclare:self.name options:self.options];
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

- (AMQBasicPublish *)amqPublish {
    return [[AMQBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                             exchange:[[AMQShortstr alloc] init:@""]
                                           routingKey:[[AMQShortstr alloc] init:@""]
                                              options:0];
}

@end
