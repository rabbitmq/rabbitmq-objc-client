#import <Foundation/Foundation.h>

@protocol AMQTransport
- (void)connect;
- (void)write:(nonnull NSData *)data;
- (BOOL)isOpen;
@end