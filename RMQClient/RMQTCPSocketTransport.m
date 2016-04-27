#import "RMQTCPSocketTransport.h"
#import "RMQSynchronizedMutableDictionary.h"
#import "RMQConstants.h"

long closeTag = UINT32_MAX + 1;
long writeTag = UINT32_MAX + 2;

@interface RMQTCPSocketTransport ()

@property (nonatomic, readwrite) NSString *host;
@property (nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) BOOL _isConnected;
@property (nonatomic, readwrite) GCDAsyncSocket *socket;
@property (nonatomic, readwrite) id callbacks;
@property (nonatomic, readwrite) NSNumber *connectTimeout;

@end

@implementation RMQTCPSocketTransport
@synthesize delegate;

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port callbackStorage:(id)callbacks {
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        self.host = host;
        self.port = port;
        self.callbacks = callbacks;
        self.connectTimeout = @2;
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    return [self initWithHost:host port:port callbackStorage:[RMQSynchronizedMutableDictionary new]];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)connectAndReturnError:(NSError *__autoreleasing  _Nullable *)error {
    return [self.socket connectToHost:self.host
                               onPort:self.port.unsignedIntegerValue
                                error:error];
}

- (void)close:(void (^)())onClose {
    self.callbacks[@(closeTag)] = [onClose copy];
    [self.socket disconnectAfterReadingAndWriting];
}

- (void)write:(NSData *)data {
    [self.socket writeData:data
               withTimeout:10
                       tag:writeTag];
}

struct __attribute__((__packed__)) AMQPHeader {
    UInt8  type;
    UInt16 channel;
    UInt32 size;
};

#define AMQP_HEADER_SIZE 7
#define AMQP_FINAL_OCTET_SIZE 1

- (void)readFrame:(void (^)(NSData * _Nonnull))complete {
    [self read:AMQP_HEADER_SIZE complete:^(NSData * _Nonnull data) {
        const struct AMQPHeader *header;
        header = (const struct AMQPHeader *)data.bytes;
        
        UInt32 hostSize = CFSwapInt32BigToHost(header->size);
        
        [self read:hostSize complete:^(NSData * _Nonnull payload) {
            [self read:AMQP_FINAL_OCTET_SIZE complete:^(NSData * _Nonnull frameEnd) {
                NSMutableData *allData = [data mutableCopy];
                [allData appendData:payload];
                complete(allData);
            }];
        }];
    }];
}

- (BOOL)isConnected {
    return self._isConnected;
}

# pragma mark - Private

- (void)read:(NSUInteger)len complete:(void (^)(NSData * _Nonnull))complete {
    [self.socket readDataToLength:len
                      withTimeout:10
                              tag:[self storeCallback:complete]];
}

- (long)storeCallback:(id)callback {
    uint32_t tag = arc4random_uniform(INT32_MAX);
    self.callbacks[@(tag)] = [callback copy];
    return tag;
}

- (void)invokeZeroArityCallback:(long)tag {
    void (^foundCallback)() = self.callbacks[@(tag)];
    [self.callbacks removeObjectForKey:@(tag)];
    if (foundCallback) {
        foundCallback();
    }
}

- (dispatch_time_t)connectTimeoutFromNow {
    return dispatch_time(DISPATCH_TIME_NOW, self.connectTimeout.doubleValue * NSEC_PER_SEC);
}

# pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    void (^foundCallback)(NSData *) = self.callbacks[@(tag)];
    [self.callbacks removeObjectForKey:@(tag)];
    foundCallback(data);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    return 10000;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
    [self invokeZeroArityCallback:closeTag];
    [self.delegate transport:self disconnectedWithError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self invokeZeroArityCallback:tag];
}

@end
