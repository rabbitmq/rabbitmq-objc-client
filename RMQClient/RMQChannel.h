#import <Foundation/Foundation.h>
#import "RMQQueue.h"
#import "RMQExchange.h"

@interface RMQChannel : NSObject
@property (nonnull, copy, nonatomic, readonly) NSNumber *channelID;
- (nonnull instancetype)init:(nonnull NSNumber *)channelID;
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                 autoDelete:(BOOL)shouldAutoDelete
                  exclusive:(BOOL)isExclusive;
- (nonnull RMQExchange *)defaultExchange;
- (nonnull RMQChannel *)open;
- (void)close;
- (BOOL)isOpen;
@end
