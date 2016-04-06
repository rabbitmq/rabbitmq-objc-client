#import "RMQSynchronizedMutableDictionary.h"

@interface RMQSynchronizedMutableDictionary ()
@property (nonatomic, readwrite) NSMutableDictionary *backingDictionary;
@property (nonatomic, readwrite) NSUInteger count;
@property (nonatomic, readwrite) NSObject *lock;
@end

@implementation RMQSynchronizedMutableDictionary

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backingDictionary = [NSMutableDictionary new];
        self.lock = [NSObject new];
        self.count = 0;
    }
    return self;
}

- (id)objectForKeyedSubscript:(NSNumber *)key {
    return self.backingDictionary[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSNumber *)key {
    @synchronized (self.lock) {
        self.backingDictionary[key] = obj;
        self.count++;
    }
}

- (void)removeObjectForKey:(NSNumber *)key {
    @synchronized (self.lock) {
        [self.backingDictionary removeObjectForKey:key];
        self.count--;
    }
}

@end
