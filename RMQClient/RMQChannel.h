#import <Foundation/Foundation.h>
#import "RMQExchange.h"
#import "RMQQueue.h"
#import "RMQFrameHandler.h"

@protocol RMQChannel <NSObject, RMQFrameHandler>
@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;
- (nonnull RMQExchange *)defaultExchange;
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                 autoDelete:(BOOL)shouldAutoDelete
                  exclusive:(BOOL)isExclusive;
- (void)basicConsume:(nonnull NSString *)queueName
            consumer:(void (^ _Nonnull)(id <RMQMessage> _Nonnull))consumer;
@end
