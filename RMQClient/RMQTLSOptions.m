#import "RMQTLSOptions.h"

@interface RMQTLSOptions ()
@property (nonatomic, readwrite) BOOL useTLS;
@property (nonatomic, readwrite) BOOL verifyPeer;
@end

@implementation RMQTLSOptions

- (instancetype)initWithUseTLS:(BOOL)useTLS
                    verifyPeer:(BOOL)verifyPeer {
    self = [super init];
    if (self) {
        self.useTLS = useTLS;
        self.verifyPeer = verifyPeer;
    }
    return self;
}

@end
