#import <Foundation/Foundation.h>

@protocol RMQTransport
- (void)connect:(void (^ _Nonnull)())onConnect;
- (void)close:(void (^ _Nonnull)())onClose;
- (_Nullable id<RMQTransport>)write:(nonnull NSData *)data
                              error:(NSError * _Nullable * _Nullable)error
                         onComplete:(void (^ _Nonnull)())complete;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end