#import <Foundation/Foundation.h>
#import "AMQValues.h"

@protocol RMQTransport <AMQIncomingCallbackContext>
- (void)connect:(void (^ _Nonnull)())onConnect;
- (_Nullable id<RMQTransport>)write:(nonnull NSData *)data
                              error:(NSError * _Nullable * _Nullable)error
                         onComplete:(void (^ _Nonnull)())complete;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end