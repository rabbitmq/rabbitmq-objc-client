#import <Foundation/Foundation.h>
#import "RMQFrameset.h"

@interface RMQFramesetWaitResult : NSObject
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) RMQFrameset *frameset;

- (instancetype)initWithFrameset:(RMQFrameset *)frameset error:(NSError *)error;
@end