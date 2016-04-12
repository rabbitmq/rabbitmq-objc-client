#import <Foundation/Foundation.h>
#import "AMQFrameset.h"

@interface RMQFramesetWaitResult : NSObject
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) AMQFrameset *frameset;

- (instancetype)initWithFrameset:(AMQFrameset *)frameset error:(NSError *)error;
@end