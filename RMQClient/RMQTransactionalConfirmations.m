#import "RMQTransactionalConfirmations.h"
#import "RMQConfirmationTransaction.h"

@interface RMQTransactionalConfirmations ()
@property (nonatomic, readwrite) NSUInteger offset;
@property (nonatomic, readwrite) NSUInteger nextPublishSequenceNumber;
@property (nonatomic, readwrite) NSMutableArray *transactions;
@property (nonatomic, readwrite) NSUInteger transactionIndex;
@end

@implementation RMQTransactionalConfirmations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.offset = 0;
        self.nextPublishSequenceNumber = 0;
        self.transactions = [NSMutableArray new];
        [self addTransaction];
        self.transactionIndex = 0;
    }
    return self;
}

- (void)enable {
    self.nextPublishSequenceNumber = 1;
}

- (BOOL)isEnabled {
    return self.nextPublishSequenceNumber > 0;
}

- (void)recover {
    self.offset = self.nextPublishSequenceNumber - 1;
    [self.currentTransaction clearUnconfirmed];
}

- (void)addPublication {
    if (self.isEnabled) {
        [self.currentTransaction addUnconfirmed:@(self.nextPublishSequenceNumber++)];
    }
}

- (void)addCallback:(RMQConfirmationCallback)callback {
    self.currentTransaction.callback = callback;
    [self.currentTransaction completeIfReady];
    [self addTransaction];
}

- (void)ack:(RMQBasicAck *)ack {
    for (NSNumber *tag in [self offsetTags:ack]) {
        [[self transactionForUnconfirmedTag:tag] ack:tag];
    }
}

- (void)nack:(RMQBasicNack *)nack {
    for (NSNumber *tag in [self offsetTags:nack]) {
        [[self transactionForUnconfirmedTag:tag] nack:tag];
    }
}

#pragma mark - Private

- (RMQConfirmationTransaction *)transactionForUnconfirmedTag:(NSNumber *)tag {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(RMQConfirmationTransaction *tx, NSDictionary<NSString *,id> * bindings) {
        return [tx isUnconfirmed:tag];
    }];
    NSArray *filtered = [self.transactions filteredArrayUsingPredicate:pred];
    return filtered.count > 0 ? filtered[0] : nil;
}

- (RMQConfirmationTransaction *)currentTransaction {
    return self.transactions[self.transactionIndex];
}

- (void)addTransaction {
    [self.transactions addObject:[RMQConfirmationTransaction new]];
    self.transactionIndex++;
}

- (NSArray *)offsetTags:(id)ackOrNack {
    RMQBasicAck *ack = (RMQBasicAck *)ackOrNack;
    uint64_t highestTag = ack.deliveryTag.integerValue;
    BOOL isMultiple = ack.options & RMQBasicAckMultiple;
    uint64_t lowestTag = isMultiple ? 1 : highestTag;

    NSMutableArray *tags = [NSMutableArray new];
    for (uint64_t tag = lowestTag; tag <= highestTag; tag++) {
        [tags addObject:@(tag + self.offset)];
    }
    return tags;
}

@end
