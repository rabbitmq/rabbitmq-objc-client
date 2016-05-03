#import <Foundation/Foundation.h>
#import "RMQTransport.h"
#import "RMQTLSOptions.h"
@import CocoaAsyncSocket;

@interface RMQTCPSocketTransport : NSObject<RMQTransport,GCDAsyncSocketDelegate>

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                          tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                     callbackStorage:(nonnull id)callbacks;

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                          tlsOptions:(nonnull RMQTLSOptions *)tlsOptions;

@end
