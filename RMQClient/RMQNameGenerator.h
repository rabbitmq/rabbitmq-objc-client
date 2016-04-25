#import <Foundation/Foundation.h>

@protocol RMQNameGenerator <NSObject>

- (NSString *)generateWithPrefix:(NSString *)prefix;

@end
