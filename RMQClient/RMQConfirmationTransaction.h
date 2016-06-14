#import <Foundation/Foundation.h>
#import "RMQConfirmations.h"

@interface RMQConfirmationTransaction : NSObject

@property (nonatomic, readwrite) RMQConfirmationCallback callback;
@property (nonatomic, readwrite) NSMutableSet *unconfirmed;
@property (nonatomic, readwrite) NSMutableSet *confirmedAcks;
@property (nonatomic, readwrite) NSMutableSet *confirmedNacks;

- (void)addUnconfirmed:(NSNumber *)tag;
- (void)clearUnconfirmed;
- (void)ack:(NSNumber *)tag;
- (void)nack:(NSNumber *)tag;
- (BOOL)isUnconfirmed:(NSNumber *)tag;
- (void)completeIfReady;

@end
