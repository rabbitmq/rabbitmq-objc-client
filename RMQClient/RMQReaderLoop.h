#import <Foundation/Foundation.h>
#import "RMQTransport.h"
#import "RMQFrameHandler.h"

@interface RMQReaderLoop : NSObject
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler;
- (void)runOnce;
@end
