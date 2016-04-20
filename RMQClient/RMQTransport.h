#import <Foundation/Foundation.h>
#import "RMQValues.h"
#import "RMQTransportDelegate.h"

@protocol RMQTransport <RMQIncomingCallbackContext>
@property (nullable, nonatomic, readwrite) id<RMQTransportDelegate> delegate;
- (BOOL)connectAndReturnError:(NSError * _Nullable * _Nullable)error;
- (void)write:(nonnull NSData *)data;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end