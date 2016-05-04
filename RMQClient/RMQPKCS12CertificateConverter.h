#import <Foundation/Foundation.h>

@interface RMQPKCS12CertificateConverter : NSObject

- (instancetype)initWithData:(NSData *)data
                    password:(NSString *)password;

- (NSArray *)certificatesWithError:(NSError **)error;

@end
