#import <Foundation/Foundation.h>
#import "RMQMessage.h"
#import "RMQSender.h"

@protocol RMQChannel;

@interface RMQQueue : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             channel:(nonnull id <RMQChannel>)channel
                              sender:(nonnull id <RMQSender>)sender;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (nonnull id<RMQMessage>)pop;
- (void)subscribe:(void (^ _Nonnull)(id<RMQMessage> _Nonnull))handler;

@end
