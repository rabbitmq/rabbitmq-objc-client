//
//  RMQClientConnection.m
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import "RMQClientConnection.h"

@implementation RMQClientConnection
- (void)start {
    
}
- (RMQClientChannel *)createChannel {
    return [RMQClientChannel new];
}
@end
