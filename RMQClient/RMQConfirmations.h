#import <Foundation/Foundation.h>
#import "RMQMethods.h"

typedef void (^RMQConfirmationCallback)(NSSet<NSNumber *> *, NSSet<NSNumber *> *);

@protocol RMQConfirmations <NSObject>
- (void)enable;
- (BOOL)isEnabled;
- (void)recover;
- (void)addPublication;
- (void)addCallback:(RMQConfirmationCallback)callback;
- (void)ack:(RMQBasicAck *)ack;
- (void)nack:(RMQBasicNack *)nack;
@end
