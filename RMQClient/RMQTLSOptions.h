#import <Mantle/Mantle.h>

@interface RMQTLSOptions : MTLModel

@property (nonatomic, readonly) BOOL useTLS;
@property (nonatomic, readonly) NSString *peerName;
@property (nonatomic, readonly) BOOL verifyPeer;

- (instancetype)initWithUseTLS:(BOOL)useTLS
                      peerName:(NSString *)peerName
                    verifyPeer:(BOOL)verifyPeer;

- (NSDictionary *)startTLSOptions;
- (NSString *)authMechanism;

@end
