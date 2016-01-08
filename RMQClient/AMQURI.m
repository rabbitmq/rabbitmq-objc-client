//
//  AMQURI.m
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import "AMQURI.h"

@interface AMQURI ()
@property (nonatomic,nonnull,readwrite) NSString *scheme;
@property (nonatomic,nonnull,readwrite) NSString *host;
@property (nonatomic,nonnull,readwrite) NSString *vhost;
@property (nonatomic,nonnull,readwrite) NSNumber *portNumber;
@property (nonatomic,readwrite) BOOL isSSL;
@end

@implementation AMQURI
+ (id)parse:(NSString *)uri error:(NSError *__autoreleasing  _Nullable *)error {
    NSURLComponents *components = [NSURLComponents componentsWithString:uri];
    if ([components.scheme containsString:@"amqp"]) {
        AMQURI *u = [[AMQURI alloc] init];
        u.host = components.host;
        
        if ([components.path isEqualToString:@"/"]) {
            u.vhost = @"";
        } else {
            u.vhost = @"/";
        }

        if ([components.scheme isEqualToString:@"amqp"]) {
            u.portNumber = @5672;
            u.scheme = @"amqp";
            u.isSSL = NO;
        } else if ([components.scheme isEqualToString:@"amqps"]) {
            u.portNumber = @5671;
            u.scheme = @"amqps";
            u.isSSL = YES;
        }
        
        return u;
    } else {
        *error = [NSError errorWithDomain:@"AMQ"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK", nil)}];
    }
    return nil;
}
@end
