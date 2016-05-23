#import <Foundation/Foundation.h>
#import "RMQTransport.h"
#import "RMQFrameHandler.h"

@interface RMQReader : NSObject
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler;
- (void)run;
@end
