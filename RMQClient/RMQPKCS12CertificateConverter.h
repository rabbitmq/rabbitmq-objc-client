#import <Foundation/Foundation.h>
#import "RMQCertificateConverter.h"

@interface RMQPKCS12CertificateConverter : NSObject <RMQCertificateConverter>

- (instancetype)initWithData:(NSData *)data
                    password:(NSString *)password;

@end
