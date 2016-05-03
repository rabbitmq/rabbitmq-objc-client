#import "RMQTLSOptions.h"
#import "RMQTCPSocketTransport.h"

@interface RMQTLSOptions ()
@property (nonatomic, readwrite) BOOL useTLS;
@property (nonatomic, readwrite) NSString *peerName;
@property (nonatomic, readwrite) BOOL verifyPeer;
@property (nonatomic, readwrite) NSData *pkcs12data;
@end

@implementation RMQTLSOptions

+ (instancetype)noTLS {
    return [[RMQTLSOptions alloc] initWithUseTLS:NO peerName:@"" verifyPeer:NO pkcs12:nil];
}

- (instancetype)initWithUseTLS:(BOOL)useTLS
                      peerName:(NSString *)peerName
                    verifyPeer:(BOOL)verifyPeer
                        pkcs12:(NSData *)pkcs12data {
    self = [super init];
    if (self) {
        self.useTLS = useTLS;
        self.peerName = peerName;
        self.verifyPeer = verifyPeer;
        self.pkcs12data = pkcs12data;
    }
    return self;
}

- (instancetype)initWithPeerName:(NSString *)peerName
                      verifyPeer:(BOOL)verifyPeer
                          pkcs12:(NSData *)pkcs12data {
    return [self initWithUseTLS:YES
                       peerName:peerName
                     verifyPeer:verifyPeer
                         pkcs12:pkcs12data];
}

- (NSDictionary *)startTLSOptions {
    return @{GCDAsyncSocketManuallyEvaluateTrust: @(!self.verifyPeer),
             GCDAsyncSocketSSLPeerName: self.peerName};
}

- (NSString *)authMechanism {
    return self.pkcs12data ? @"EXTERNAL" : @"PLAIN";
}

@end
