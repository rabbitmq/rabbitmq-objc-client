#import <Foundation/Foundation.h>
#import "RMQFrameset.h"

@protocol RMQSender <NSObject>
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
- (void)sendFrameset:(nonnull RMQFrameset *)frameset;
- (void)sendFrameset:(nonnull RMQFrameset *)frameset force:(BOOL)isForced;
@end
