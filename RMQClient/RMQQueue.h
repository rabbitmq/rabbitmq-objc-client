#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQMessage.h"
#import "RMQSender.h"

@protocol RMQChannel;

@interface RMQQueue : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             options:(RMQQueueDeclareOptions)options
                             channel:(nonnull id <RMQChannel>)channel
                              sender:(nonnull id <RMQSender>)sender;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             channel:(nonnull id <RMQChannel>)channel
                              sender:(nonnull id <RMQSender>)sender;

- (nonnull RMQQueue *)publish:(nonnull NSString *)message;
- (void)pop:(void (^ _Nonnull)(id<RMQMessage> _Nonnull message))handler;
- (void)subscribe:(void (^ _Nonnull)(id<RMQMessage> _Nonnull message))handler;
- (void)subscribe:(RMQBasicConsumeOptions)options
          handler:(void (^ _Nonnull)(id<RMQMessage> _Nonnull message))handler;

@end
