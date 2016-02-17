#import "RMQConnection.h"
#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"
#import "RMQReaderLoop.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) AMQTable *clientProperties;
@property (nonatomic, readwrite) NSString *mechanism;
@property (nonatomic, readwrite) NSString *locale;
@property (nonatomic, readwrite) AMQCredentials *credentials;
@property (nonatomic, readwrite) NSDictionary *channels;
@property (nonatomic, readwrite) RMQReaderLoop *readerLoop;
@property (nonatomic, readwrite) id <RMQIDAllocator> idAllocator;
@property (nonatomic, readwrite) RMQQueueFactory *queueFactory;
@end

@implementation RMQConnection

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id<RMQTransport>)transport
                 idAllocator:(id<RMQIDAllocator>)idAllocator {
    self = [super init];
    if (self) {
        self.credentials = [[AMQCredentials alloc] initWithUsername:user
                                                           password:password];
        self.vhost = vhost;
        self.transport = transport;
        self.idAllocator = idAllocator;
        AMQTable *capabilities = [[AMQTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                          @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                          @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                          @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                          @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                          @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
        self.clientProperties = [[AMQTable alloc] init:
                                 @{@"capabilities" : capabilities,
                                   @"product"     : [[AMQLongstr alloc] init:@"RMQClient"],
                                   @"platform"    : [[AMQLongstr alloc] init:@"iOS"],
                                   @"version"     : [[AMQLongstr alloc] init:@"0.0.1"],
                                   @"information" : [[AMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];
        self.mechanism = @"PLAIN";
        self.locale = @"en_GB";
        self.readerLoop = [[RMQReaderLoop alloc] initWithTransport:self.transport frameHandler:self];
        self.queueFactory = [[RMQQueueFactory alloc] initWithConnection:self];
        self.channels = @{@0 : [[RMQChannel alloc] init:@0
                                              transport:self.transport
                                           replyContext:self
                                           queueFactory:self.queueFactory]};
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (RMQConnection *)start {
    [self.transport connect:^{
        NSError *error = NULL;
        [self.transport write:[AMQProtocolHeader new].amqEncoded
                        error:&error
                   onComplete:^{ [self.readerLoop runOnce]; }];
    }];
    return self;
}

- (void)close {
    AMQProtocolConnectionClose *method = self.amqClose;
    AMQFrame *frame = [[AMQFrame alloc] initWithChannelID:@0 payload:method];
    NSError *error = NULL;
    [self.transport write:frame.amqEncoded error:&error onComplete:^{}];
}

- (RMQChannel *)createChannel {
    RMQChannel *ch = [[RMQChannel alloc] init:[self.idAllocator nextID]
                                    transport:self.transport
                                 replyContext:self
                                 queueFactory:self.queueFactory];
    AMQFrame *frame = [[AMQFrame alloc] initWithChannelID:ch.channelID payload:self.amqChannelOpen];
    NSError *error = NULL;
    [self.transport write:frame.amqEncoded error:&error onComplete:^{}];
    return ch;
}

- (void)sendMethod:(id<AMQMethod>)amqMethod channelID:(NSNumber *)channelID {
    [self send:[[AMQFrame alloc] initWithChannelID:channelID payload:amqMethod]];
    if ([self shouldSendNextRequest:amqMethod]) {
        [self sendMethod:[(id <AMQOutgoingPrecursor>)amqMethod nextRequest] channelID:channelID];
    }
}

- (void)send:(id<AMQEncoding>)encodable {
    NSError *error = NULL;
    [self.transport write:encodable.amqEncoded
                    error:&error
               onComplete:^{}];
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    id method = frameset.method;
    if ([self shouldReply:method]) {
        id<AMQMethod> reply = [method replyWithContext:self];
        [self sendMethod:reply channelID:frameset.channelID];
    }
    if ([self shouldTriggerCallback:method]) {
        [method didReceiveWithContext:self.transport];
    }
    [self.readerLoop runOnce];
}

# pragma mark - Private

- (AMQProtocolChannelOpen *)amqChannelOpen {
    return [[AMQProtocolChannelOpen alloc] initWithReserved1:[[AMQShortstr alloc] init:@""]];
}

- (AMQProtocolConnectionClose *)amqClose {
    return [[AMQProtocolConnectionClose alloc] initWithReplyCode:[[AMQShort alloc] init:200]
                                                       replyText:[[AMQShortstr alloc] init:@"Goodbye"]
                                                         classId:[[AMQShort alloc] init:0]
                                                        methodId:[[AMQShort alloc] init:0]];
}

- (BOOL)shouldReply:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQIncomingSync)];
}

- (BOOL)shouldSendNextRequest:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQOutgoingPrecursor)];
}

- (BOOL)shouldTriggerCallback:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQIncomingCallback)];
}

@end
