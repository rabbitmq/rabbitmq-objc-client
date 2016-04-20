#import "RMQProtocolHeader.h"
#import "RMQMethods.h"

@implementation RMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer;
    int length = asprintf(&buffer, "AMQP%c%c%c%c", 0, 0, 9, 1);
    return [NSData dataWithBytesNoCopy:buffer length:length];
}

- (Class)expectedResponseClass {
    return [RMQConnectionStart class];
}

@end
