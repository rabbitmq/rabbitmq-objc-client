#import "AMQMethodFrame.h"

@implementation AMQMethodFrame

- (id<AMQProtocolMethod>)parse:(NSData *)data {
    NSRange range = NSMakeRange(4, data.length - 4); // ignore classID and methodID for now
    return [AMQProtocolConnectionStart decode:[data subdataWithRange:range]];
}

@end
