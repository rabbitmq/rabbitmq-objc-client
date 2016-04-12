#import <Foundation/Foundation.h>
#import "RMQFrameHandler.h"
#import "RMQSender.h"
#import "RMQConnectionConfig.h"
#import "RMQReaderLoop.h"

@interface RMQHandshaker : NSObject <RMQFrameHandler>
@property (nonatomic, readwrite) RMQReaderLoop *readerLoop;
- (instancetype)initWithSender:(id<RMQSender>)sender
                        config:(RMQConnectionConfig *)config
             completionHandler:(void (^)())completionHandler;
@end
