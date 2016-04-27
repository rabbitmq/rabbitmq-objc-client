#import <Foundation/Foundation.h>
#import "RMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)sendFrameset:(nonnull RMQFrameset *)frameset;
@end
