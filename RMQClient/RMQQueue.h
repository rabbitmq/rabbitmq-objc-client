#import <Foundation/Foundation.h>
#import "RMQMessage.h"
#import "RMQSender.h"

@interface RMQQueue : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                           channelID:(nonnull NSNumber *)channelID
                              sender:(nonnull id <RMQSender>)sender;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (nonnull id<RMQMessage>)pop;
@end
