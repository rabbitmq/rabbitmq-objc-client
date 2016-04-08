#import <Foundation/Foundation.h>
#import "AMQValues.h"

@protocol RMQTransport <AMQIncomingCallbackContext>
- (BOOL)connectAndReturnError:(NSError * _Nullable * _Nullable)error
                   onComplete:(void (^ _Nonnull)())complete;
- (BOOL)write:(nonnull NSData *)data
        error:(NSError * _Nullable * _Nullable)error
   onComplete:(void (^ _Nonnull)())complete;
- (void)readFrame:(void (^ _Nonnull)(NSData * _Nonnull))complete;
- (BOOL)isConnected;
@end