//
//  RMQClientTests.m
//  RMQClientTests
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RMQClientConnection.h"

@interface RMQClientTests : XCTestCase

@end

@implementation RMQClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIntegration {
    RMQClientConnection *conn = [RMQClientConnection new];
    [conn start];
    
    RMQClientChannel *ch = [conn createChannel];
    
    RMQClientQueue *q = [ch queue:@"rmqclient.examples.hello_world" autoDelete:YES];
    RMQClientExchange *x = [ch defaultExchange];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"subscription data received"];
    
    NSDictionary *expectedInfo = @{@"consumer_tag" : @"foo"};
    NSDictionary *expectedMeta = @{@"foo" : @"bar"};
    NSDictionary *expectedPayload = @{@"baz" : @"qux"};
    
    [q subscribe:^void(NSDictionary *info, NSDictionary *meta, NSDictionary *p) {
        if ([info isEqual:expectedInfo] && [meta isEqual:expectedMeta] && [p isEqual:expectedPayload]) {
            [expectation fulfill];
        } else {
            XCTFail(@"subscribe response unexpected");
        }
    }];
    
    [x publish:@"Hello!" routingKey:q.name];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
