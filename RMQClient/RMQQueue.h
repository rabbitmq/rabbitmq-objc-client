#import <Foundation/Foundation.h>
#import "RMQMessage.h"
#import "RMQSender.h"

@interface RMQQueue : NSObject
@property (nonnull, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithChannelID:(nonnull NSNumber *)channelID
                                   sender:(nonnull id <RMQSender>)sender;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (nonnull id<RMQMessage>)pop;
@end
