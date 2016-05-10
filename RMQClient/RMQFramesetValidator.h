#import <Foundation/Foundation.h>
#import "RMQFramesetValidationResult.h"

@interface RMQFramesetValidator : NSObject
- (RMQFramesetValidationResult *)expect:(Class)methodClass;
- (void)fulfill:(RMQFrameset *)frameset;
@end