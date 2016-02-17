#import "RMQQueue.h"
#import "AMQProtocolMethods.h"
#import "RMQConnection.h"
#import "AMQProtocolBasicProperties.h"

@interface RMQQueue ()
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@property (weak, nonatomic, readwrite) NSNumber *channelID;
@end

@implementation RMQQueue

- (instancetype)initWithChannelID:(NSNumber *)channelID sender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.sender = sender;
    }
    return self;
}

- (RMQQueue *)publish:(NSString *)message {
    AMQProtocolBasicPublish *method = [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                                exchange:[[AMQShortstr alloc] init:@""]
                                                                              routingKey:[[AMQShortstr alloc] init:@""]
                                                                                 options:0];
    NSData *contentBodyData = [message dataUsingEncoding:NSUTF8StringEncoding];
    AMQContentBody *contentBody = [[AMQContentBody alloc] initWithData:contentBodyData];

    AMQBasicDeliveryMode *persistent = [[AMQBasicDeliveryMode alloc] init:2];
    AMQBasicContentType *contentTypeOctetStream = [[AMQBasicContentType alloc] init:@"application/octet-stream"];
    AMQBasicPriority *lowPriority = [[AMQBasicPriority alloc] init:0];

    AMQContentHeader *contentHeader = [[AMQContentHeader alloc] initWithClassID:@60
                                                                       bodySize:@(contentBodyData.length)
                                                                     properties:@[persistent, contentTypeOctetStream, lowPriority]];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:self.channelID
                                                            method:method
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
