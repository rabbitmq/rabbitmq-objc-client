#import <Foundation/Foundation.h>

@protocol RMQTransport
- (void)connect:(void (^ _Nonnull)())onConnect;
- (void)close:(void (^ _Nonnull)())onClose;
- (nullable NSString *)write:(nonnull NSData *)data
                       error:(NSError * _Nullable * _Nullable)error
                  onComplete:(void (^ _Nonnull)())complete;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end