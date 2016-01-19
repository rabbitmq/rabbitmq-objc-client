#import "AMQProtocol.h"
#import "AMQParser.h"

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
    char    versionMajor;
    char    versionMinor;
};

+ (instancetype)decode:(NSData *)data {
//    NSData *d = [NSData dataWithBytesNoCopy:(void *)data.bytes length:data.length];
//    NSString* dataFormatString = @"data:application/octet-stream;base64,%@";
//    NSString* dataString = [NSString stringWithFormat:dataFormatString, [d base64EncodedStringWithOptions:0]];
//    NSURL* dataURL = [NSURL URLWithString:dataString];

    const struct AMQPConnectionStart *cs;
    cs = (const struct AMQPConnectionStart *)data.bytes;

    char versionMajor = cs->versionMajor;
    char versionMinor = cs->versionMinor;
    
    const char *cursor = (const char *)data.bytes + sizeof(*cs);
    const char *end = (const char *)data.bytes + data.length;
    
    AMQParser *parser = [AMQParser new];
    NSDictionary *serverProperties = [parser parseFieldTable:&cursor end:end];
    
    /* cursor == start of the last two Connection.Start fields */
    NSString *mechanisms = [parser parseLongString:&cursor end:end];
    NSString *locales = [parser parseLongString:&cursor end:end];

    return [[AMQProtocolConnectionStart alloc] initWithVersionMajor:@(versionMajor)
                                                       versionMinor:@(versionMinor)
                                                   serverProperties:serverProperties];
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