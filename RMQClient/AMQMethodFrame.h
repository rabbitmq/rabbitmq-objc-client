#import <Foundation/Foundation.h>
#import "AMQProtocol.h"

@interface AMQMethodFrame : NSObject

- (id)parse:(NSData *)data;

@end
