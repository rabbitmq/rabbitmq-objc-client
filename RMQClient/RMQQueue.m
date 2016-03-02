#import "RMQQueue.h"
#import "AMQProtocolMethods.h"
#import "RMQConnection.h"
#import "AMQProtocolBasicProperties.h"
#import "AMQConstants.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@property (nonatomic, readwrite) NSNumber *channelID;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     channel:(RMQDispatchQueueChannel *)channel
                      sender:(id<RMQSender>)sender {
   self = [super init];
    if (self) {
        self.name = name;
        self.channelID = channel.channelID;
        self.sender = sender;
    }
    return self;
}

- (RMQQueue *)publish:(NSString *)message {
    AMQProtocolBasicPublish *publish = [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                                 exchange:[[AMQShortstr alloc] init:@""]
                                                                               routingKey:[[AMQShortstr alloc] init:self.name]
                                                                                  options:AMQProtocolBasicPublishNoOptions];
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
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:self.channelID
                                                            method:publish
                                                     contentHeader:contentHeader
                                                     contentBodies:contentBodies];
    [self.sender send:frameset];
    return self;
}

- (id<RMQMessage>)pop {
    AMQProtocolBasicGet *get = [[AMQProtocolBasicGet alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                        queue:[[AMQShortstr alloc] init:self.name]
                                                                      options:AMQProtocolBasicGetNoOptions];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:self.channelID
                                                            method:get
                                                     contentHeader:[AMQContentHeaderNone new]
                                                     contentBodies:@[]];
    [self.sender send:frameset];

    NSError *error = NULL;
    [self.sender waitOnMethod:[AMQProtocolBasicGetOk class]
                    channelID:self.channelID
                        error:&error];

    if (error) {
        NSLog(@"\n**** ERROR WAITING FOR GET-OK %@", error);
    }

    AMQFrameset *getOk = self.sender.lastWaitedUponFrameset;

    NSString *content = [[NSString alloc] initWithData:getOk.contentData
                                              encoding:NSUTF8StringEncoding];

    return [[RMQContentMessage alloc] initWithDeliveryInfo:@{@"consumer_tag": @"foo"}
                                                  metadata:@{@"foo": @"bar"}
                                                   content:content];
}

# pragma mark - Private

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

- (AMQProtocolBasicPublish *)amqPublish {
    return [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                     exchange:[[AMQShortstr alloc] init:@""]
                                                   routingKey:[[AMQShortstr alloc] init:@""]
                                                      options:0];
}

@end
