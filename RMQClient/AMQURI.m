//
//  AMQURI.m
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import "AMQURI.h"

@implementation AMQURI
+ (id)parse:(NSString *)uri error:(NSError *__autoreleasing *)error {
    *error = [NSError errorWithDomain:@"AMQ"
                                 code:0
                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK", nil)}];
    return nil;
}
@end
