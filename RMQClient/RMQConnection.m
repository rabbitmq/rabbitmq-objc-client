#import "AMQConstants.h"
#import "AMQFrame.h"
#import "AMQMethods.h"
#import "AMQProtocolHeader.h"
#import "AMQURI.h"
#import "RMQConnection.h"
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
@property (nonatomic, readwrite) NSMutableDictionary *anticipatedFramesetSemaphores;
@property (nonatomic, readwrite) NSMutableDictionary *anticipatedFramesets;
@property (nonatomic, readwrite) NSNumber *frameMax;
@property (nonatomic, readwrite) NSNumber *syncTimeout;
@property (nonatomic, weak, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) dispatch_queue_t delegateQueue;
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
                         delegate:(id<RMQConnectionDelegate>)delegate
                    delegateQueue:(dispatch_queue_t)delegateQueue {
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
        self.syncTimeout = syncTimeout;
        RMQMultipleChannelAllocator *allocator = [[RMQMultipleChannelAllocator alloc] initWithSender:self];
        self.channelAllocator = allocator;
        self.frameHandler = allocator;
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

        self.channels = [NSMutableDictionary new];
        self.anticipatedFramesetSemaphores = [NSMutableDictionary new];
        self.anticipatedFramesets = [NSMutableDictionary new];
        self.delegate = delegate;
        self.delegateQueue = delegateQueue;

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
    return [self initWithTransport:transport
                              user:amqURI.username
                          password:amqURI.password
                             vhost:amqURI.vhost
                        channelMax:channelMax
                          frameMax:frameMax
                         heartbeat:heartbeat
                       syncTimeout:syncTimeout
                          delegate:delegate
                     delegateQueue:delegateQueue];
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

- (instancetype)init
{
    return [self initWithUri:@"amqp://guest:guest@localhost"
                    delegate:nil];
}

- (void)start {
    NSError *connectError = NULL;
    __block NSError *writeError = NULL;

    [self.transport connectAndReturnError:&connectError onComplete:^{
        [self.transport write:[AMQProtocolHeader new].amqEncoded
                        error:&writeError
                   onComplete:^{ [self.readerLoop runOnce]; }];
    }];

    if (connectError)    [self sendDelegateError:connectError];
    else if (writeError) [self sendDelegateError:writeError];
    else                 [self waitForConnectionHandshakeToComplete];
}

- (void)close {
    AMQConnectionClose *method = self.amqClose;
    AMQFrame *frame = [[AMQFrame alloc] initWithChannelNumber:@0 payload:method];
    NSError *error = NULL;
    [self.transport write:frame.amqEncoded error:&error onComplete:^{}];
}

- (id<RMQChannel>)createChannelWithError:(NSError *__autoreleasing  _Nullable *)error {
    id<RMQChannel> ch = self.channelAllocator.allocate;
    self.channels[ch.channelNumber] = ch;
    AMQFrame *frame = [[AMQFrame alloc] initWithChannelNumber:ch.channelNumber payload:self.amqChannelOpen];
    if ([self.transport write:frame.amqEncoded error:error onComplete:^{}]) {
        return ch;
    } else {
        return nil;
    }
}

# pragma mark - RMQSender

- (void)sendMethod:(id<AMQMethod>)amqMethod channelNumber:(NSNumber *)channelNumber {
    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:channelNumber method:amqMethod];
    [self sendFrameset:frameset error:NULL];
    if ([self shouldSendNextRequest:amqMethod]) {
        [self sendMethod:[(id <AMQOutgoingPrecursor>)amqMethod nextRequest] channelNumber:channelNumber];
    }
}

- (BOOL)sendFrameset:(AMQFrameset *)frameset
               error:(NSError *__autoreleasing  _Nullable *)error {
    return [self.transport write:frameset.amqEncoded
                           error:error
                      onComplete:^{}];
}

- (AMQFrameset *)sendFrameset:(AMQFrameset *)frameset
                 waitOnMethod:(Class)amqMethodClass
                        error:(NSError *__autoreleasing  _Nullable *)error {
    if ([self sendFrameset:frameset error:error]) {
        return [self waitOnMethod:amqMethodClass
                    channelNumber:frameset.channelNumber
                            error:error];
    } else {
        return nil;
    }
}

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(AMQFrameset *)frameset {
    id method = frameset.method;
    NSArray *watchedMethod = @[frameset.channelNumber, [method class]];

    dispatch_semaphore_t foundSemaphore = self.anticipatedFramesetSemaphores[watchedMethod];
    if (foundSemaphore) {
        self.anticipatedFramesets[frameset.channelNumber] = frameset;
        dispatch_semaphore_signal(foundSemaphore);
    }
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

# pragma mark - Private

- (void)waitForConnectionHandshakeToComplete {
    NSError *waitError = NULL;
    [self waitOnMethod:[AMQConnectionOpenOk class] channelNumber:@0 error:&waitError];
    if (waitError) [self sendDelegateError:waitError];
}

- (AMQFrameset *)waitOnMethod:(Class)amqMethodClass
                channelNumber:(NSNumber *)channelNumber
                        error:(NSError *__autoreleasing  _Nullable *)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray *watchedMethod = @[channelNumber, amqMethodClass];

    self.anticipatedFramesetSemaphores[watchedMethod] = semaphore;
    if (dispatch_semaphore_wait(semaphore, self.syncTimeoutFromNow) == 0) {
        [self.anticipatedFramesetSemaphores removeObjectForKey:watchedMethod];
        AMQFrameset *foundFrameset = self.anticipatedFramesets[channelNumber];
        [self.anticipatedFramesets removeObjectForKey:channelNumber];
        return foundFrameset;
    } else {
        NSString *errorMessage = [NSString stringWithFormat:@"Timed out waiting for %@", amqMethodClass];
        *error = [NSError errorWithDomain:RMQErrorDomain
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        return nil;
    }
}

- (void)sendDelegateError:(NSError *)error {
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

- (AMQChannelOpen *)amqChannelOpen {
    return [[AMQChannelOpen alloc] initWithReserved1:[[AMQShortstr alloc] init:@""]];
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
