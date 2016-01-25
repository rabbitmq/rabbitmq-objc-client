#import <Foundation/Foundation.h>

@interface AMQCredentials : NSObject<NSCoding>

- (instancetype)initWithUsername:(NSString *)username
                        password:(NSString *)password;

@end
