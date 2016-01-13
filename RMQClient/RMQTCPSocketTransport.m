#import "RMQTCPSocketTransport.h"

@interface RMQTCPSocketTransport ()
@property (nonnull, nonatomic, readwrite) NSString *host;
@property (nonnull, nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) BOOL _isConnected;
@property (nonnull, nonatomic, readwrite) GCDAsyncSocket *socket;
@property (nonnull, nonatomic, readwrite) NSMutableDictionary *callbacks;
@end

typedef enum AMQP_TAGS : NSUInteger {
    AMQPTagHeader,
    AMQP_TAGS_SIZE
} AMQP_TAGS;

@implementation RMQTCPSocketTransport

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.host = host;
        self.port = port;
        self.callbacks = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)connect {
    NSError *error = nil;
    if (![self.socket connectToHost:self.host onPort:self.port.unsignedIntegerValue error:&error]) {
        NSLog(@"*************** Something is very wrong: %@", error);
    }
}

- (void)close {
    [self.socket disconnectAfterReadingAndWriting];
}


- (void)write:(NSData *)data onComplete:(void (^)())complete {
    uint32_t tag = [self generateTag];
    [self.callbacks setObject:[complete copy] forKey:@(tag)];
    [self.socket writeData:data withTimeout:10 tag:tag];
}

struct __attribute__((__packed__)) AMQPHeader {
    char           type;
    unsigned short channel;
    unsigned long  size;
};

#define AMQP_HEADER_SIZE 7
#define AMQP_FINAL_OCTET_SIZE 1

- (void)readFrame:(void (^)(NSData * _Nonnull))complete {
    [self read:AMQP_HEADER_SIZE complete:^(NSData * _Nonnull data) {
        const struct AMQPHeader *header;
        header = (const struct AMQPHeader *)data.bytes;
        
        char              hostType = ntohl(header->type);
        unsigned short hostChannel = ntohl(header->channel);
        unsigned long     hostSize = ntohl(header->size);
        
        NSLog(@"<<<<<<<<<< HEADER type %d channel %d size %lu", hostType, hostChannel, hostSize);
        
        [self read:hostSize complete:^(NSData * _Nonnull payload) {
            NSLog(@"%@", payload);
            
            [self read:AMQP_FINAL_OCTET_SIZE complete:^(NSData * _Nonnull frameEnd) {
                NSLog(@"FRAME END: %@", frameEnd);
                
                // hardcode parse as a Connection Start for now
            }];
        }];
    }];
}

- (void)read:(NSUInteger)len complete:(void (^)(NSData * _Nonnull))complete {
    uint32_t tag = [self generateTag];
    [self.callbacks setObject:[complete copy] forKey:@(tag)];
    [self.socket readDataToLength:len withTimeout:10 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    void (^foundCallback)() = [self.callbacks objectForKey:@(tag)];
    foundCallback(data);
}

- (BOOL)isConnected {
    return self._isConnected;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    void (^foundCallback)() = [self.callbacks objectForKey:@(tag)];
    foundCallback();
}

- (uint32_t)generateTag {
    return arc4random_uniform(INT32_MAX - AMQP_TAGS_SIZE) + AMQP_TAGS_SIZE;
}

@end
