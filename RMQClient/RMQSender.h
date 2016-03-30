#import <Foundation/Foundation.h>
#import "AMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)sendFrameset:(nonnull AMQFrameset *)frameset;
- (nullable AMQFrameset *)sendFrameset:(nonnull AMQFrameset *)frameset
                          waitOnMethod:(nonnull Class)amqMethodClass
                                 error:(NSError * _Nullable * _Nullable)error;
- (void)sendMethod:(nonnull id<AMQMethod>)amqMethod
     channelNumber:(nonnull NSNumber *)channelNumber;
@end
