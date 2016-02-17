#import "RMQQueue.h"
#import "AMQProtocolMethods.h"
#import "RMQChannel.h"
#import "RMQConnection.h"

@interface RMQQueue ()
@property (weak, nonatomic, readwrite) RMQConnection *connection;
@property (weak, nonatomic, readwrite) RMQChannel *channel;
@end

@implementation RMQQueue

- (instancetype)initWithConnection:(RMQConnection *)connection
                           channel:(RMQChannel *)channel {
    self = [super init];
    if (self) {
        self.connection = connection;
        self.channel = channel;
    }
    return self;
}

- (RMQQueue *)publish:(NSString *)message {
    AMQProtocolBasicPublish *method = [[AMQProtocolBasicPublish alloc] initWithReserved1:[[AMQShort alloc] init:0]
                                                                                exchange:[[AMQShortstr alloc] init:@""]
                                                                              routingKey:[[AMQShortstr alloc] init:@""]
                                                                               mandatory:[[AMQBit alloc] init:0]
                                                                               immediate:[[AMQBit alloc] init:0]];
    NSData *contentBodyData = [message dataUsingEncoding:NSUTF8StringEncoding];
    AMQContentBody *contentBody = [[AMQContentBody alloc] initWithData:contentBodyData];
    AMQContentHeader *contentHeader = [[AMQContentHeader alloc] initWithClassID:@60
                                                                       bodySize:@(contentBodyData.length)
                                                                     properties:@[]];
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:self.channel.channelID
                                                            method:method
                                                     contentHeader:contentHeader
                                                     contentBodies:@[contentBody]];
    [self.connection send:frameset];
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
                                                    mandatory:[[AMQBit alloc] init:0]
                                                    immediate:[[AMQBit alloc] init:0]];
}

@end
