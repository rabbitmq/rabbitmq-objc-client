#import "AMQMethodFrame.h"
#import "AMQDecoder.h"

@implementation AMQMethodFrame

- (id)parse:(NSData *)data {
    if (!data.length) {
        return nil;
    }
    
    NSRange range = NSMakeRange(4, data.length - 4); // ignore classID and methodID for now
    AMQDecoder *coder = [[AMQDecoder alloc] initWithData:[data subdataWithRange:range]];
    return [[AMQProtocolConnectionStart alloc] initWithCoder:coder];
}

@end
