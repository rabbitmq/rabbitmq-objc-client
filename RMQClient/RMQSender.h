#import <Foundation/Foundation.h>
#import "RMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)sendFrameset:(nonnull RMQFrameset *)frameset;
- (void)sendMethod:(nonnull id<RMQMethod>)amqMethod
     channelNumber:(nonnull NSNumber *)channelNumber;
@end
