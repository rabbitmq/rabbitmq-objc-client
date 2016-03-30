#import <Foundation/Foundation.h>
#import "AMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)sendFrameset:(nonnull AMQFrameset *)frameset;
- (void)sendMethod:(nonnull id<AMQMethod>)amqMethod
     channelNumber:(nonnull NSNumber *)channelNumber;
- (nullable AMQFrameset *)waitOnMethod:(nonnull Class)amqMethodClass
                         channelNumber:(nonnull NSNumber *)channelNumber
                                 error:(NSError * _Nullable * _Nullable)error;
@end
