#import <Foundation/Foundation.h>
#import "RMQTransport.h"

@interface RMQTCPSocketTransport : NSObject<RMQTransport,NSStreamDelegate>

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port;

@end
