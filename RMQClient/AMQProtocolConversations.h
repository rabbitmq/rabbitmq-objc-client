#import <Foundation/Foundation.h>
#import "AMQProtocolMethods.h"

@interface AMQProtocolConnectionStart (Conversation) <AMQIncomingSync>
@end

@interface AMQProtocolConnectionStartOk (Conversation) <AMQOutgoingSync>
@end

@interface AMQProtocolConnectionTune (Conversation) <AMQIncomingSync>
@end

@interface AMQProtocolConnectionTuneOk (Conversation) <AMQOutgoingPrecursor>
@end