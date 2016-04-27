#import <Foundation/Foundation.h>
#import "RMQTransport.h"
@import CocoaAsyncSocket;

@interface RMQTCPSocketTransport : NSObject<RMQTransport,GCDAsyncSocketDelegate>

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                              useTLS:(BOOL)useTLS
                          verifyPeer:(BOOL)verifyPeer
                     callbackStorage:(nonnull id)callbacks;

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                              useTLS:(BOOL)useTLS
                          verifyPeer:(BOOL)verifyPeer;

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                              useTLS:(BOOL)useTLS;

@end
