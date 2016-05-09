#import <Mantle/Mantle.h>

@interface RMQTLSOptions : MTLModel

@property (nonatomic, readonly) BOOL useTLS;
@property (nonatomic, readonly) NSString *peerName;
@property (nonatomic, readonly) BOOL verifyPeer;

+ (instancetype)fromURI:(NSString *)uri verifyPeer:(BOOL)verifyPeer;
+ (instancetype)fromURI:(NSString *)uri;
- (instancetype)initWithPeerName:(NSString *)peerName
                      verifyPeer:(BOOL)verifyPeer
                          pkcs12:(NSData *)pkcs12data
                  pkcs12Password:(NSString *)password;

- (NSString *)authMechanism;
- (NSArray *)certificatesWithError:(NSError **)error;

@end
