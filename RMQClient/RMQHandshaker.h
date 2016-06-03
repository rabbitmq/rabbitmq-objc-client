#import <Foundation/Foundation.h>
#import "RMQFrameHandler.h"
#import "RMQMethods.h"
#import "RMQSender.h"
#import "RMQConnectionConfig.h"
#import "RMQReader.h"

@interface RMQHandshaker : NSObject <RMQFrameHandler>
@property (weak, nonatomic, readwrite) RMQReader *reader;
- (instancetype)initWithSender:(id<RMQSender>)sender
                        config:(RMQConnectionConfig *)config
             completionHandler:(void (^)(NSNumber *heartbeatTimeout))completionHandler;
@end
