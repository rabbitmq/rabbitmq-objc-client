#import "RMQGCDSerialQueue.h"

@interface RMQGCDSerialQueue ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) dispatch_queue_t dispatchQueue;
@end

@implementation RMQGCDSerialQueue

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        NSString *qName = [NSString stringWithFormat:@"RMQGCDSerialQueue (%@)", name];
        self.dispatchQueue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)enqueue:(RMQOperation)operation {
    dispatch_async(self.dispatchQueue, operation);
}

- (void)blockingEnqueue:(RMQOperation)operation {
    dispatch_sync(self.dispatchQueue, operation);
}

- (void)suspend {
    dispatch_suspend(self.dispatchQueue);
}

- (void)resume {
    dispatch_resume(self.dispatchQueue);
}

@end
