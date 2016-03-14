#import <Foundation/Foundation.h>
#import "AMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) AMQFrameset *lastWaitedUponFrameset;
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)send:(nonnull id<AMQEncoding>)encodable;
- (void)sendMethod:(nonnull id<AMQMethod>)amqMethod
     channelNumber:(nonnull NSNumber *)channelNumber;
- (nullable AMQFrameset *)waitOnMethod:(nonnull Class)amqMethodClass
                         channelNumber:(nonnull NSNumber *)channelNumber
                                 error:(NSError * _Nullable * _Nullable)error;
@end
