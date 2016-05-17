#import <Foundation/Foundation.h>
#import "RMQConnectionDelegate.h"
#import "RMQFrameset.h"

@protocol RMQDispatcher <NSObject, RMQFrameHandler>

- (void)blockingWaitOn:(Class)method;

- (void)activateWithChannel:(id<RMQChannel>)channel
                   delegate:(id<RMQConnectionDelegate>)delegate;

- (void)sendSyncMethod:(id<RMQMethod>)method
     completionHandler:(void (^)(RMQFrameset *frameset))completionHandler;

- (void)sendSyncMethod:(id<RMQMethod>)method;

- (void)sendSyncMethodBlocking:(id<RMQMethod>)method;

- (void)sendAsyncMethod:(id<RMQMethod>)method;

- (void)sendAsyncFrameset:(RMQFrameset *)frameset;

@end
