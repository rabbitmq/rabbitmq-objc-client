#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) AMQFrameset *lastWaitedUponFrameset;
- (void)send:(nonnull id<AMQEncoding>)encodable;
- (void)sendMethod:(nonnull id<AMQMethod>)amqMethod
         channelID:(nonnull NSNumber *)channelID;
- (BOOL)waitOnMethod:(nonnull Class)amqMethodClass
           channelID:(nonnull NSNumber *)channelID
               error:(NSError * _Nullable * _Nullable)error;
@end
