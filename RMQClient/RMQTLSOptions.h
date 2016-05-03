#import <Mantle/Mantle.h>

@interface RMQTLSOptions : MTLModel

@property (nonatomic, readonly) BOOL useTLS;
@property (nonatomic, readonly) BOOL verifyPeer;

- (instancetype)initWithUseTLS:(BOOL)useTLS
                    verifyPeer:(BOOL)verifyPeer;

@end
