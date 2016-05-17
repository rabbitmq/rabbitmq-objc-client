#import <Foundation/Foundation.h>
#import "RMQStarter.h"

@protocol RMQConnectionRecovery <NSObject>

- (void)recover;

@end
