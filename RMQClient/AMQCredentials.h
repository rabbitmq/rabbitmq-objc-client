#import <Foundation/Foundation.h>
@import Mantle;

@interface AMQCredentials : MTLModel

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

- (instancetype)initWithUsername:(NSString *)username
                        password:(NSString *)password;

@end
