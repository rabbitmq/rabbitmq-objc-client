#import "RMQSynchronizedMutableDictionary.h"

@interface RMQSynchronizedMutableDictionary ()
@property (nonatomic, readwrite) NSMutableDictionary *backingDictionary;
@property (nonatomic, readwrite) NSObject *lock;
@end

@implementation RMQSynchronizedMutableDictionary

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backingDictionary = [NSMutableDictionary new];
        self.lock = [NSObject new];
    }
    return self;
}

- (id)objectForKeyedSubscript:(NSNumber *)key {
    return self.backingDictionary[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSNumber *)key {
    @synchronized (self.lock) {
        self.backingDictionary[key] = obj;
    }
}

- (void)removeObjectForKey:(NSNumber *)key {
    [self.backingDictionary removeObjectForKey:key];
}

@end
