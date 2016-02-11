#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"

@implementation AMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer;
    int length = asprintf(&buffer, "AMQP%c%c%c%c", 0, 0, 9, 1);
    return [NSData dataWithBytesNoCopy:buffer length:length];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionStart class];
}

@end
