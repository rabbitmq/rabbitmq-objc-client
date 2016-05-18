#import <Foundation/Foundation.h>
#import "RMQConsumerDeliveryHandler.h"

@protocol RMQChannel;

@interface RMQConsumer : NSObject

@property (nonatomic, readonly) NSString *tag;
@property (nonatomic, readonly) RMQConsumerDeliveryHandler handler;

- (instancetype)initWithConsumerTag:(NSString *)tag
                            handler:(RMQConsumerDeliveryHandler)handler
                            channel:(id<RMQChannel>)channel;
- (void)cancel;

@end
