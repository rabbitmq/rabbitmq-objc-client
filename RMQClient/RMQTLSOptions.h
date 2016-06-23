#import "RMQValues.h"

@interface RMQTLSOptions : RMQValue

@property (nonatomic, readonly) BOOL useTLS;
@property (nonatomic, readonly) BOOL verifyPeer;
@property (nonnull, nonatomic, readonly) NSString *peerName;

+ (nonnull instancetype)fromURI:(nonnull NSString *)uri verifyPeer:(BOOL)verifyPeer;
+ (nonnull instancetype)fromURI:(nonnull NSString *)uri;
- (nonnull instancetype)initWithPeerName:(nonnull NSString *)peerName
                              verifyPeer:(BOOL)verifyPeer
                                  pkcs12:(nullable NSData *)pkcs12data
                          pkcs12Password:(nullable NSString *)password;

- (nonnull NSString *)authMechanism;
- (nullable NSArray *)certificatesWithError:(NSError *_Nullable *_Nullable)error;

@end
