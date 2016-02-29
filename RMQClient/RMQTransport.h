#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"
#import <PromiseKit/PromiseKit.h>
@import PromiseKit;

@protocol RMQTransport <AMQIncomingCallbackContext>
- (void)connect:(void (^ _Nonnull)())onConnect;
- (_Nullable id<RMQTransport>)write:(nonnull NSData *)data
                              error:(NSError * _Nullable * _Nullable)error
                         onComplete:(void (^ _Nonnull)())complete;
- (nonnull AnyPromise *)readFrame;
- (BOOL)isConnected;
@end