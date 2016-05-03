#import "RMQTLSOptions.h"
#import "RMQTCPSocketTransport.h"

@interface RMQTLSOptions ()
@property (nonatomic, readwrite) BOOL useTLS;
@property (nonatomic, readwrite) NSString *peerName;
@property (nonatomic, readwrite) BOOL verifyPeer;
@end

@implementation RMQTLSOptions

- (instancetype)initWithUseTLS:(BOOL)useTLS
                      peerName:(NSString *)peerName
                    verifyPeer:(BOOL)verifyPeer {
    self = [super init];
    if (self) {
        self.useTLS = useTLS;
        self.peerName = peerName;
        self.verifyPeer = verifyPeer;
    }
    return self;
}

- (NSDictionary *)startTLSOptions {
    return @{GCDAsyncSocketManuallyEvaluateTrust: @(!self.verifyPeer),
             GCDAsyncSocketSSLPeerName: self.peerName};
}

- (NSString *)authMechanism {
    return @"PLAIN";
}

@end
