#import <Foundation/Foundation.h>
#import "AMQMethods.h"

@interface AMQConnectionStart (Conversation) <AMQIncomingSync>
@end

@interface AMQConnectionTune (Conversation) <AMQIncomingSync>
@end

@interface AMQConnectionTuneOk (Conversation) <AMQOutgoingPrecursor>
@end

@interface AMQConnectionClose (Conversation) <AMQIncomingSync>
@end
