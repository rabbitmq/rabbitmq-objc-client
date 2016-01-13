#import <Foundation/Foundation.h>

@protocol RMQTransport
- (void)connect;
- (void)close;
- (void)write:(nonnull NSData *)data;
- (nonnull NSData *)read; // TODO: return a domain object, not NSData
- (BOOL)isConnected;
@end