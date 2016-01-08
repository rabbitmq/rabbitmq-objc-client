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
    
    if (![self isAMQPScheme:components.scheme]) {
        *error = [NSError errorWithDomain:@"AMQ"
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Connection URI must use amqp or amqps schema (example: amqp://bus.megacorp.internal:5766), learn more at http://bit.ly/ks8MXK", nil)}];
        return nil;
    }

    NSError *parseVhostError = NULL;
    NSString *vhost = [self parseVhost:components error:&parseVhostError];
    if (parseVhostError) {
        *error = parseVhostError;
        return nil;
    }
    
    AMQURI *u = [[AMQURI alloc] init];
    u.host = components.host;
    u.vhost = vhost;
    
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
}

+ (BOOL)isAMQPScheme:(NSString *)scheme {
    return [scheme isEqualToString:@"amqp"] || [scheme isEqualToString:@"amqps"];
}

+ (NSString *)parseVhost:(NSURLComponents *)components error:(NSError **)error {
    NSRegularExpression *r = [NSRegularExpression
                              regularExpressionWithPattern:@"/"
                              options:NSRegularExpressionCaseInsensitive
                              error:NULL];
    NSUInteger numberOfSlashes = [r numberOfMatchesInString:components.path options:0 range:NSMakeRange(0, components.path.length)];
    
    if (numberOfSlashes > 2) {
        NSString *msg = [NSString stringWithFormat:@"%@ has multiple-segment path; please percent-encode any slashes in the vhost name (e.g. /production => %%2Fproduction). Learn more at http://bit.ly/amqp-gem-and-connection-uris", components.URL];
        *error = [NSError errorWithDomain:@"AMQ" code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)}];
        return nil;
    } else if (components.path.length == 0) {
        return @"/";
    } else {
        return [components.path substringFromIndex:1];
    }
}
@end
