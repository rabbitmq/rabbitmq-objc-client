#import "AMQProtocol.h"

@interface AMQProtocolBasicConsumeOK ()
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *consumerTag;
@end

@implementation AMQProtocolBasicConsumeOK

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"consume-ok";
        self.consumerTag = @"amq.ctag.foobar";
    }
    return self;
}

@end

@interface AMQProtocolMethodFrame ()
@property (copy, nonatomic, readwrite) NSData *payload;
@property (copy, nonatomic, readwrite) NSNumber *channel;
@end

@implementation AMQProtocolMethodFrame

- (instancetype)initWithPayload:(NSData *)payload
                        channel:(NSNumber *)channel {
    self = [super init];
    if (self) {
        self.payload = payload;
        self.channel = channel;
    }
    return self;
}

- (NSData *)encode {
    return [NSData new];
}

@end

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) NSDictionary<NSString *, NSString *> *serverProperties;
@end

@implementation AMQProtocolConnectionStart

struct __attribute__((__packed__)) AMQPConnectionStart {
    UInt16  classID;
    UInt16  methodID;
    
    char    versionMajor;
    char    versionMinor;
    UInt32  tableLength;
};

+ (instancetype)decode:(NSData *)data {
    const struct AMQPConnectionStart *cs;
    cs = (const struct AMQPConnectionStart *)data.bytes;
    
    char versionMajor = cs->versionMajor;
    char versionMinor = cs->versionMinor;
    int tableLength   = CFSwapInt32BigToHost(cs->tableLength);

    return [[AMQProtocolConnectionStart alloc] initWithVersionMajor:@(versionMajor)
                                                       versionMinor:@(versionMinor)
                                                   serverProperties:@{}];
}
- (instancetype)initWithVersionMajor:(NSNumber *)versionMajor
                        versionMinor:(NSNumber *)versionMinor
                    serverProperties:(NSDictionary<NSString *,NSString *> *)serverProperties {
    self = [super init];
    if (self) {
        self.serverProperties = serverProperties;
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
    }
    return self;
}
@end