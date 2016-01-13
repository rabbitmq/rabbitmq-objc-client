#import <Foundation/Foundation.h>

@protocol RMQTransport
- (void)connect;
- (void)close;
- (void)write:(nonnull NSData *)data
   onComplete:(void (^ _Nonnull)())complete;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end