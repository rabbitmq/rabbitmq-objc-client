#import <Foundation/Foundation.h>

@interface RMQURI : NSObject
@property (nonatomic,nonnull,readonly) NSString *scheme;
@property (nonatomic,nonnull,readonly) NSString *host;
@property (nonatomic,nonnull,readonly) NSString *vhost;
@property (nonatomic,nonnull,readonly) NSNumber *portNumber;
@property (nonatomic,nonnull,readonly) NSString *username;
@property (nonatomic,nonnull,readonly) NSString *password;
@property (nonatomic,readonly) BOOL isTLS;

+ (nullable instancetype)parse:(nonnull NSString *)uri error:(NSError * _Nullable * _Nullable)error;
@end
