#import <Foundation/Foundation.h>

@interface AMQProtocolBasicConsumeOK : NSObject
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *consumerTag;
@end
