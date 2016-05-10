#import "RMQFramesetValidationResult.h"

@interface RMQFramesetValidationResult ()
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) RMQFrameset *frameset;
@end

@implementation RMQFramesetValidationResult

- (instancetype)initWithFrameset:(RMQFrameset *)frameset error:(NSError *)error {
    self = [super init];
    if (self) {
        self.frameset = frameset;
        self.error = error;
    }
    return self;
}

@end
