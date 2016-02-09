#import <Foundation/Foundation.h>
#import "RMQMessage.h"

@interface RMQQueue : NSObject
@property (nonatomic, readonly) NSString *name;
- (RMQQueue *)publish:(NSString *)message;
- (RMQMessage *)pop;
@end
