#import "RMQQueue.h"
#import "AMQProtocolMethods.h"
#import "RMQConnection.h"
#import "AMQProtocolBasicProperties.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@property (weak, nonatomic, readwrite) NSNumber *channelID;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                   channelID:(NSNumber *)channelID
                      sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.name = name;
        self.channelID = channelID;
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

    AMQContentHeader *contentHeader = [[AMQContentHeader alloc] initWithClassID:publish.classID
                                                                       bodySize:@(contentBodyData.length)
                                                                     properties:@[persistent, octetStream, lowPriority]];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:self.channelID
                                                            method:publish
                                                     contentHeader:contentHeader
                                                     contentBodies:@[contentBody]];
    [self.sender send:frameset];
    return self;
}

- (id<RMQMessage>)pop {
    return [[RMQContentMessage alloc] initWithDeliveryInfo:@{@"consumer_tag": @"foo"}
                                                  metadata:@{@"foo": @"bar"}
                                                   content:@"Hello!"];
}

- (AMQProtocolBasicPublish *)amqPublish {
    return [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                     exchange:[[AMQShortstr alloc] init:@""]
                                                   routingKey:[[AMQShortstr alloc] init:@""]
                                                      options:0];
}

@end
