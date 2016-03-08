#import "RMQTCPSocketTransport.h"

long connectTag = UINT32_MAX + 1;
long closeTag   = UINT32_MAX + 2;

@interface RMQTCPSocketTransport ()

@property (nonnull, nonatomic, readwrite) NSString *host;
@property (nonnull, nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) BOOL _isConnected;
@property (nonnull, nonatomic, readwrite) GCDAsyncSocket *socket;
@property (nonnull, nonatomic, readwrite) NSMutableDictionary *callbacks;
@property (nonatomic, readwrite) dispatch_semaphore_t connectSemaphore;

@end

@implementation RMQTCPSocketTransport

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    return [self initWithHost:host port:port callbackStorage:[NSMutableDictionary new]];
}

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port callbackStorage:(NSMutableDictionary *)callbacks {
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        self.host = host;
        self.port = port;
        self.callbacks = callbacks;
        self.connectSemaphore = nil;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)connect:(void (^)())onConnect {
    self.connectSemaphore = dispatch_semaphore_create(0);

    NSError *error = nil;
    [self.callbacks setObject:[onConnect copy] forKey:@(connectTag)];
    if (![self.socket connectToHost:self.host onPort:self.port.unsignedIntegerValue error:&error]) {
        NSLog(@"*************** Something is very wrong: %@", error);
        [self.callbacks removeObjectForKey:@(connectTag)];
    }

    dispatch_semaphore_wait(self.connectSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)close:(void (^)())onClose {
    [self.callbacks setObject:[onClose copy] forKey:@(closeTag)];
    [self.socket disconnectAfterReadingAndWriting];
}

- (id<RMQTransport>)write:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error onComplete:(void (^)())complete {
    if (self._isConnected) {
        [self.socket writeData:data
                   withTimeout:10
                           tag:[self storeCallback:complete]];
        return self;
    } else {
        *error = [NSError errorWithDomain:@"AMQ"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Not connected", nil)}];
        return nil;
    }
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
    [self.callbacks setObject:[callback copy] forKey:@(tag)];
    return tag;
}

- (void)invokeZeroArityCallback:(long)tag {
    void (^foundCallback)() = self.callbacks[@(tag)];
    if (foundCallback) {
        foundCallback();
        [self.callbacks removeObjectForKey:@(tag)];
    }
}

# pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    void (^foundCallback)() = self.callbacks[@(tag)];
    foundCallback(data);
    [self.callbacks removeObjectForKey:@(tag)];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
    [self invokeZeroArityCallback:connectTag];
    dispatch_semaphore_signal(self.connectSemaphore);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
    [self invokeZeroArityCallback:closeTag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self invokeZeroArityCallback:tag];
}

@end
