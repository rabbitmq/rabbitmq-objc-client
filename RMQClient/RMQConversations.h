#import <Foundation/Foundation.h>
#import "RMQMethods.h"

@interface RMQConnectionStart (Conversation) <RMQIncomingSync>
@end

@interface RMQConnectionTune (Conversation) <RMQIncomingSync>
@end

@interface RMQConnectionTuneOk (Conversation) <RMQOutgoingPrecursor>
@end

@interface RMQConnectionClose (Conversation) <RMQIncomingSync>
@end
