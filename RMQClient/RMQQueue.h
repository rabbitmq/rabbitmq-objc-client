#import <Foundation/Foundation.h>
#import "RMQMessage.h"
#import "RMQChannel.h"

@interface RMQQueue : NSObject
@property (nonnull, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithChannel:(nonnull RMQChannel *)channel;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (nonnull id<RMQMessage>)pop;
@end
