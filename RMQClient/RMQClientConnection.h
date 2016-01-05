//
//  RMQClientConnection.h
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMQClientChannel.h"

@interface RMQClientConnection : NSObject
- (void)start;
- (RMQClientChannel *)createChannel;
@end
