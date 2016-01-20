#import "AMQProtocol.h"
#import "AMQParser.h"

@interface AMQProtocolBasicConsumeOk ()
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *consumerTag;
@end

@implementation AMQProtocolBasicConsumeOk

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"consume-ok";
        self.consumerTag = @"amq.ctag.foobar";
    }
    return self;
}

@end

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) NSDictionary<NSObject *, NSObject *> *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) NSString *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) NSString *locales;
@end

@implementation AMQProtocolConnectionStart

struct __attribute__((__packed__)) AMQPConnectionStart {
    char    versionMajor;
    char    versionMinor;
};

+ (instancetype)decode:(NSData *)data {
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
                                                   serverProperties:serverProperties
                                                         mechanisms:mechanisms
                                                            locales:locales];
}

- (instancetype)initWithVersionMajor:(NSNumber *)versionMajor
                        versionMinor:(NSNumber *)versionMinor
                    serverProperties:(NSDictionary<NSObject *,NSObject *> *)serverProperties
                          mechanisms:(NSString *)mechanisms
                             locales:(NSString *)locales {
    self = [super init];
    if (self) {
        self.serverProperties = serverProperties;
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
        self.mechanisms = mechanisms;
        self.locales = locales;
    }
    return self;
}

@end