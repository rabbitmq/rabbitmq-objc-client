#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQLocalSerialQueue.h"
#import "RMQNameGenerator.h"
#import "RMQDispatcher.h"

@interface RMQAllocatedChannel : MTLModel <RMQChannel>
- (nonnull instancetype)init:(nonnull NSNumber *)channelNumber
             contentBodySize:(nonnull NSNumber *)contentBodySize
                  dispatcher:(nonnull id<RMQDispatcher>)dispatcher
                commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
               nameGenerator:(nullable id<RMQNameGenerator>)nameGenerator;
@end
