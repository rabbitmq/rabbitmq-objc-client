#import <Foundation/Foundation.h>
#import "RMQFramesetValidator.h"
#import "RMQLocalSerialQueue.h"
#import "RMQSender.h"
#import "RMQDispatcher.h"

@interface RMQSuspendResumeDispatcher : NSObject <RMQDispatcher>

- (instancetype)initWithSender:(id<RMQSender>)sender
                  commandQueue:(id<RMQLocalSerialQueue>)commandQueue;

@end
