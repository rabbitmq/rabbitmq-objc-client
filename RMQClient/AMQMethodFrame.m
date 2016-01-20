#import "AMQMethodFrame.h"
#import "AMQCoder.h"

@implementation AMQMethodFrame

- (id)parse:(NSData *)data {
    NSRange range = NSMakeRange(4, data.length - 4); // ignore classID and methodID for now
    AMQCoder *coder = [[AMQCoder alloc] initWithData:[data subdataWithRange:range]];
    return [[AMQProtocolConnectionStart alloc] initWithCoder:coder];
}

@end
