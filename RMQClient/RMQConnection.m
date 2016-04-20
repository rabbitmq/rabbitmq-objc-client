#import "AMQConstants.h"
#import "AMQFrame.h"
#import "AMQMethods.h"
#import "AMQProtocolHeader.h"
#import "AMQURI.h"
#import "RMQConnection.h"
#import "RMQHandshaker.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQReaderLoop.h"
#import "RMQTCPSocketTransport.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) AMQTable *clientProperties;
@property (nonatomic, readwrite) NSString *mechanism;
@property (nonatomic, readwrite) NSString *locale;
@property (nonatomic, readwrite) RMQConnectionConfig *config;
@property (nonatomic, readwrite) RMQReaderLoop *readerLoop;
@property (nonatomic, readwrite) id <RMQChannelAllocator> channelAllocator;
@property (nonatomic, readwrite) id <RMQFrameHandler> frameHandler;
@property (nonatomic, readwrite) NSMutableDictionary *channels;
@property (nonatomic, readwrite) NSNumber *frameMax;
@property (nonatomic, readwrite) NSNumber *syncTimeout;
@property (nonatomic, weak, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) dispatch_queue_t delegateQueue;
@property (nonatomic, readwrite) dispatch_queue_t networkQueue;
@property (nonatomic, readwrite) BOOL handshakeComplete;
@property (nonatomic, readwrite) BOOL closing;
@end

@implementation RMQConnection

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                             user:(NSString *)user
                         password:(NSString *)password
                            vhost:(NSString *)vhost
                       channelMax:(NSNumber *)channelMax
                         frameMax:(NSNumber *)frameMax
                        heartbeat:(NSNumber *)heartbeat
                      syncTimeout:(NSNumber *)syncTimeout
                 channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                     frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                         delegate:(id<RMQConnectionDelegate>)delegate
                    delegateQueue:(dispatch_queue_t)delegateQueue
                     networkQueue:(nonnull dispatch_queue_t)networkQueue {
    self = [super init];
    if (self) {
        AMQCredentials *credentials = [[AMQCredentials alloc] initWithUsername:user
                                                                      password:password];
        self.config = [[RMQConnectionConfig alloc] initWithCredentials:credentials
                                                            channelMax:channelMax
                                                              frameMax:frameMax
                                                             heartbeat:heartbeat];
        self.frameMax = frameMax;
        self.vhost = vhost;
        self.transport = transport;
        self.transport.delegate = self;
        self.syncTimeout = syncTimeout;
        self.channelAllocator = channelAllocator;
        self.channelAllocator.sender = self;
        self.frameHandler = frameHandler;
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
                                   @"information" : [[AMQLongstr alloc] init:@"https://github.com/rabbitmq/rabbitmq-objc-client"]}];
        self.mechanism = @"PLAIN";
        self.locale = @"en_GB";
        self.readerLoop = [[RMQReaderLoop alloc] initWithTransport:self.transport frameHandler:self];

        self.channels = [NSMutableDictionary new];
        self.delegate = delegate;
        self.delegateQueue = delegateQueue;
        self.networkQueue = networkQueue;
        self.handshakeComplete = NO;
        self.closing = NO;

        [self allocateChannelZero];
    }
    return self;
}

- (instancetype)initWithUri:(NSString *)uri
                 channelMax:(NSNumber *)channelMax
                   frameMax:(NSNumber *)frameMax
                  heartbeat:(NSNumber *)heartbeat
                syncTimeout:(NSNumber *)syncTimeout
                   delegate:(id<RMQConnectionDelegate>)delegate
              delegateQueue:(dispatch_queue_t)delegateQueue {
    NSError *error = NULL;
    AMQURI *amqURI = [AMQURI parse:uri error:&error];
    RMQTCPSocketTransport *transport = [[RMQTCPSocketTransport alloc] initWithHost:amqURI.host port:amqURI.portNumber];
    RMQMultipleChannelAllocator *allocator = [RMQMultipleChannelAllocator new];
    return [self initWithTransport:transport
                              user:amqURI.username
                          password:amqURI.password
                             vhost:amqURI.vhost
                        channelMax:channelMax
                          frameMax:frameMax
                         heartbeat:heartbeat
                       syncTimeout:syncTimeout
                  channelAllocator:allocator
                      frameHandler:allocator
                          delegate:delegate
                     delegateQueue:delegateQueue
                      networkQueue:dispatch_queue_create("com.rabbitmq.RMQConnectionNetworkQueue", NULL)];
}

- (instancetype)initWithUri:(NSString *)uri
                   delegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:uri
                  channelMax:@(AMQChannelLimit)
                    frameMax:@131072
                   heartbeat:@0
                 syncTimeout:@10
                    delegate:delegate
               delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (instancetype)initWithDelegate:(id<RMQConnectionDelegate>)delegate {
    return [self initWithUri:@"amqp://guest:guest@localhost" delegate:delegate];
}

- (instancetype)init
{
    return [self initWithDelegate:nil];
}

- (void)start {
    NSError *connectError = NULL;

    [self.transport connectAndReturnError:&connectError];
    if (connectError) {
        [self sendDelegateConnectionError:connectError];
    } else {
        [self.transport write:[AMQProtocolHeader new].amqEncoded];
        RMQHandshaker *handshaker = [[RMQHandshaker alloc] initWithSender:self
                                                                   config:self.config
                                                        completionHandler:^{
                                                            for (id<RMQChannel> ch in self.channels.allValues) {
                                                                [ch activateWithDelegate:self.delegate];
                                                            }
                                                            self.handshakeComplete = YES;
                                                            if (self.closing) {
                                                                self.closing = NO;
                                                                [self close];
                                                            }
                                                            [self.readerLoop runOnce];
                                                        }];
        RMQReaderLoop *handshakeLoop = [[RMQReaderLoop alloc] initWithTransport:self.transport
                                                                   frameHandler:handshaker];
        handshaker.readerLoop = handshakeLoop;
        [handshakeLoop runOnce];
    }
}

- (void)close {
    if (self.handshakeComplete) {
        AMQConnectionClose *method = self.amqClose;
        AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:@0 method:method];
        [self sendFrameset:frameset];
    } else {
        self.closing = YES;
    }
}

- (id<RMQChannel>)createChannel {
    id<RMQChannel> ch = self.channelAllocator.allocate;
    self.channels[ch.channelNumber] = ch;

    if (self.handshakeComplete) {
        [ch activateWithDelegate:self.delegate];
    }

    [ch open];

    return ch;
}

# pragma mark - RMQSender

- (void)sendMethod:(id<AMQMethod>)amqMethod channelNumber:(NSNumber *)channelNumber {
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:channelNumber method:amqMethod];
    [self sendFrameset:frameset];
    if ([self shouldSendNextRequest:amqMethod]) {
        id<AMQMethod> followOn = [(id <AMQOutgoingPrecursor>)amqMethod nextRequest];
        [self sendMethod:followOn channelNumber:channelNumber];
    }
}

- (void)sendFrameset:(AMQFrameset *)frameset {
    dispatch_async(self.networkQueue, ^{
        [self.transport write:frameset.amqEncoded];
    });
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(AMQFrameset *)frameset {
    id method = frameset.method;

    if ([self shouldReply:method]) {
        id<AMQMethod> reply = [method replyWithConfig:self.config];
        [self sendMethod:reply channelNumber:frameset.channelNumber];
    }
    if (((id<AMQMethod>)method).shouldHaltOnReceipt) {
        [self.transport close:^{}];
    }
    [self.frameHandler handleFrameset:frameset];
    [self.readerLoop runOnce];
}

# pragma mark - RMQTransportDelegate

- (void)transport:(id<RMQTransport>)transport failedToWriteWithError:(NSError *)error {
    [self.delegate connection:self failedToWriteWithError:error];
}

- (void)transport:(id<RMQTransport>)transport disconnectedWithError:(NSError *)error {
    [self.delegate connection:self disconnectedWithError:error];
}

# pragma mark - Private

- (void)sendDelegateConnectionError:(NSError *)error {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate connection:self failedToConnectWithError:error];
    });
}

- (dispatch_time_t)syncTimeoutFromNow {
    return dispatch_time(DISPATCH_TIME_NOW, self.syncTimeout.doubleValue * NSEC_PER_SEC);
}

- (void)allocateChannelZero {
    [self.channelAllocator allocate];
}

- (AMQConnectionClose *)amqClose {
    return [[AMQConnectionClose alloc] initWithReplyCode:[[AMQShort alloc] init:200]
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

@end
