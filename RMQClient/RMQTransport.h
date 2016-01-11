#import <Foundation/Foundation.h>

@protocol RMQTransport
- (void)connect;
- (void)close;
- (void)write:(nonnull NSData *)data;
- (BOOL)isOpen;
@end