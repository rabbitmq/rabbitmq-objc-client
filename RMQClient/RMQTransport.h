#import <Foundation/Foundation.h>
#import "RMQTransportDelegate.h"

@protocol RMQTransport
@property (nullable, nonatomic, readwrite) id<RMQTransportDelegate> delegate;
- (BOOL)connectAndReturnError:(NSError * _Nullable * _Nullable)error;
- (void)close;
- (void)write:(nonnull NSData *)data;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (void)simulateDisconnect;
- (BOOL)isConnected;
@end