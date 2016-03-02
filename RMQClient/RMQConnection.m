#import "RMQConnection.h"
#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"
#import "RMQReaderLoop.h"
#import "AMQFrame.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) AMQTable *clientProperties;
@property (nonatomic, readwrite) NSString *mechanism;
@property (nonatomic, readwrite) NSString *locale;
@property (nonatomic, readwrite) AMQCredentials *credentials;
@property (nonatomic, readwrite) NSMutableDictionary *channels;
@property (nonatomic, readwrite) RMQReaderLoop *readerLoop;
@property (nonatomic, readwrite) id <RMQChannelAllocator> channelAllocator;
@property (nonatomic, readwrite) NSMutableArray *watchedIncomingMethods;
@property (nonatomic, readwrite) dispatch_semaphore_t methodSemaphore;
@property (atomic, readwrite) AMQFrameset *lastWaitedUponFrameset;
@property (nonatomic, readwrite) NSNumber *channelMax;
@property (nonatomic, readwrite) NSNumber *frameMax;
@property (nonatomic, readwrite) NSNumber *heartbeat;
@end

@implementation RMQConnection

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                 channelAllocator:(id<RMQChannelAllocator>)channelAllocator
                             user:(NSString *)user
                         password:(NSString *)password
                            vhost:(NSString *)vhost
                       channelMax:(NSNumber *)channelMax
                         frameMax:(NSNumber *)frameMax
                        heartbeat:(NSNumber *)heartbeat {
    self = [super init];
    if (self) {
        self.credentials = [[AMQCredentials alloc] initWithUsername:user
                                                           password:password];
        self.vhost = vhost;
        self.transport = transport;
        self.channelAllocator = channelAllocator;
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
        self.channelAllocator = channelAllocator;
        self.channels = [@{@0 : [self.channelAllocator allocateWithSender:self]} mutableCopy];
        self.watchedIncomingMethods = [NSMutableArray new];
        self.methodSemaphore = dispatch_semaphore_create(0);
        self.lastWaitedUponFrameset = nil;

        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
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

- (id<RMQChannel>)createChannel {
    id<RMQChannel> ch = [self.channelAllocator allocateWithSender:self];
    self.channels[ch.channelID] = ch;
    AMQFrame *frame = [[AMQFrame alloc] initWithChannelID:ch.channelID payload:self.amqChannelOpen];
    NSError *error = NULL;
    [self.transport write:frame.amqEncoded error:&error onComplete:^{}];
    return ch;
}

# pragma mark - RMQSender

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

- (BOOL)waitOnMethod:(Class)amqMethodClass
           channelID:(NSNumber *)channelID
               error:(NSError *__autoreleasing  _Nullable *)error {
    [self.watchedIncomingMethods addObject:@[channelID, amqMethodClass]];
    
    char delay = 10;
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    if (dispatch_semaphore_wait(self.methodSemaphore, timeout) == 0) {
        return YES;
    } else {
        NSString *errorMessage = @"Timeout";
        *error = [NSError errorWithDomain:@"com.rabbitmq.rmqconnection"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        return NO;
    }
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(AMQFrameset *)frameset {
    id method = frameset.method;
    NSArray *watchedMethod = @[frameset.channelID, [method class]];
    if ([self.watchedIncomingMethods containsObject:watchedMethod]) {
        [self.watchedIncomingMethods removeObject:watchedMethod];
        self.lastWaitedUponFrameset = frameset;
        dispatch_semaphore_signal(self.methodSemaphore);
    }
    if ([self shouldReply:method]) {
        id<AMQMethod> reply = [method replyWithContext:self];
        [self sendMethod:reply channelID:frameset.channelID];
    }
    if ([self shouldTriggerCallback:method]) {
        [method didReceiveWithContext:self.transport];
    }
    if ([frameset.method isKindOfClass:[AMQProtocolBasicDeliver class]]) {
        id<RMQChannel> ch = self.channels[frameset.channelID];
        [ch handleFrameset:frameset];
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
