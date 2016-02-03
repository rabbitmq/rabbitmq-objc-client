#import <Foundation/Foundation.h>
#import "RMQTransport.h"
@import CocoaAsyncSocket;

@interface RMQTCPSocketTransport : NSObject<RMQTransport,GCDAsyncSocketDelegate>

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port
                     callbackStorage:(nonnull NSMutableDictionary *)callbacks;

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                                port:(nonnull NSNumber *)port;

@end
