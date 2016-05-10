#import "RMQChannel.h"
#import "RMQErrors.h"
#import "RMQFramesetValidator.h"

@interface RMQFramesetValidator ()
@property (nonatomic, readwrite) RMQFrameset *lastFrameset;
@property (nonatomic, readwrite) RMQFramesetValidationResult *result;
@end

@implementation RMQFramesetValidator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastFrameset = nil;
    }
    return self;
}

- (RMQFramesetValidationResult *)expect:(Class)methodClass {
    RMQFramesetValidationResult *result;
    if (![self.lastFrameset.method isKindOfClass:methodClass]) {
        NSString *msg = [NSString stringWithFormat:@"Expected %@, got %@.", methodClass, [self.lastFrameset.method class]];
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQErrorChannelIncorrectSyncMethod
                                         userInfo:@{NSLocalizedDescriptionKey: msg}];
        result = [[RMQFramesetValidationResult alloc] initWithFrameset:self.lastFrameset error:error];
    } else {
        result = [[RMQFramesetValidationResult alloc] initWithFrameset:self.lastFrameset error:nil];
    }
    return result;
}

- (void)fulfill:(RMQFrameset *)frameset {
    self.lastFrameset = frameset;
}

@end
