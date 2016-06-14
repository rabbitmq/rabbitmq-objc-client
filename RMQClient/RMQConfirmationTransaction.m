#import "RMQConfirmationTransaction.h"

@implementation RMQConfirmationTransaction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.callback = nil;
        [self clearUnconfirmed];
        self.confirmedAcks = [NSMutableSet new];
        self.confirmedNacks = [NSMutableSet new];
    }
    return self;
}

- (void)addUnconfirmed:(NSNumber *)tag {
    [self.unconfirmed addObject:tag];
}

- (void)clearUnconfirmed {
    self.unconfirmed = [NSMutableSet new];
}

- (BOOL)isUnconfirmed:(NSNumber *)tag {
    return [self.unconfirmed containsObject:tag];
}

- (void)ack:(NSNumber *)tag {
    [self.unconfirmed removeObject:tag];
    [self.confirmedAcks addObject:tag];
    [self completeIfReady];
}

- (void)nack:(NSNumber *)tag {
    [self.unconfirmed removeObject:tag];
    [self.confirmedNacks addObject:tag];
    [self completeIfReady];
}

- (void)completeIfReady {
    if (self.callback &&
        self.unconfirmed.count == 0 &&
        (self.confirmedAcks.count > 0 || self.confirmedNacks.count > 0)) {
        self.callback(self.confirmedAcks, self.confirmedNacks);
    }
}

@end

