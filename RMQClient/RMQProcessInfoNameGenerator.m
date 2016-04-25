#import "RMQProcessInfoNameGenerator.h"

@implementation RMQProcessInfoNameGenerator

- (NSString *)generateWithPrefix:(NSString *)prefix {
    return [NSString stringWithFormat:@"%@%@", prefix, [NSProcessInfo processInfo].globallyUniqueString];
}

@end
