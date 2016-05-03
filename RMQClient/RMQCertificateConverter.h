#import <Foundation/Foundation.h>

@protocol RMQCertificateConverter <NSObject>
- (NSArray *)certificatesWithError:(NSError **)error;
@end
