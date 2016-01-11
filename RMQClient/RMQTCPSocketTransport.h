#import <Foundation/Foundation.h>
#import "RMQTransport.h"

@interface RMQTCPSocketTransport : NSObject<RMQTransport,NSStreamDelegate>
@end
