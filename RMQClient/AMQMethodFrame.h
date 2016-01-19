#import <Foundation/Foundation.h>
#import "AMQProtocol.h"

@interface AMQMethodFrame : NSObject

- (id<AMQProtocolMethod>)parse:(NSData *)data;

@end
