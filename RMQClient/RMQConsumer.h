#import <Foundation/Foundation.h>

@protocol RMQChannel;

@interface RMQConsumer : NSObject

@property (nonatomic, readonly) NSString *tag;

- (instancetype)initWithConsumerTag:(NSString *)tag
                            channel:(id<RMQChannel>)channel;
- (void)cancel;

@end
