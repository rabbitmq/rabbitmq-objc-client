#import <Foundation/Foundation.h>
#import "RMQStarter.h"

@protocol RMQConnectionRecovery <NSObject>

@property (nonatomic, readonly) NSNumber *interval;

- (void)recover;

@end
