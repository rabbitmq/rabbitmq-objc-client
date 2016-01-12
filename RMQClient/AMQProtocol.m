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

@implementation AMQProtocolConnectionClose

+ (AMQProtocolMethodFrame *)encode:(NSNumber *)replyCode
                         replyText:(NSString *)replyText
                           classID:(NSNumber *)classID
                          methodID:(NSNumber *)methodID {
    // class id is 10, method id is 50
    
//    unsigned char *buffer = malloc()
//    NSData *payload = [NSData dataWithBytesNoCopy:bytes length:sizeof(bytes)];
//    return [[AMQProtocolMethodFrame alloc] initWithPayload:payload
//                                                   channel:@0];
    return [AMQProtocolMethodFrame new];
}

+ (instancetype)decode:(NSData *)data {
    return [AMQProtocolConnectionClose new];
}

@end