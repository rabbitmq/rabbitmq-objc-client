@import Quick;
@import Nimble;
#import "JKVPerson.h"
#import "JKVMutablePerson.h"
#import "JKVClassInspector.h"
#import "JKVTypeContainer.h"
#import "JKVMutableCollections.h"
#import "JKVCollections.h"
#import "JKVRestrictedObject.h"
#import "JKVBasicValue.h"
#import "JKVObjectPrinter.h"
#import "KeyedArchiver.h"
#import "KeyedUnarchiver.h"

QuickSpecBegin(JKVValueSpec)

describe(@"JKVValue", ^{
    __block JKVPerson *person, *otherPerson;
    __block id parent;

    beforeEach(^{
        parent = [NSObject new];
        person = [[JKVPerson alloc] initWithFirstName:@"John"
                                             lastName:@"Doe"
                                                  age:28
                                              married:YES
                                               height:60.8
                                               parent:parent
                                             siblings:@[[[JKVMutablePerson alloc] initWithFixtureData]]
                                                child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
        otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                  lastName:person.lastName
                                                       age:person.age
                                                   married:person.married
                                                    height:person.height
                                                    parent:parent
                                                  siblings:@[[[JKVMutablePerson alloc] initWithFixtureData]]
                                                     child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
    });

    describe(@"descriptions", ^{
        it(@"should have a custom description", ^{
            NSString *expectedDescription = [NSString stringWithFormat:
                                             @"<JKVPerson: %p\n"
                                             @" firstName = @\"John\"\n"
                                             @"  lastName = @\"Doe\"\n"
                                             @"       age = 28\n"
                                             @"   married = 1\n"
                                             @"    height = 60.8\n"
                                             @"  siblings = @[<JKVMutablePerson: %p\n"
                                             @"                    child = nil\n"
                                             @"                firstName = @\"John\"\n"
                                             @"                 lastName = @\"Doe\"\n"
                                             @"                      age = 28\n"
                                             @"                  married = 1\n"
                                             @"                   height = 60.8\n"
                                             @"                   parent = nil\n"
                                             @"                 siblings = nil>]\n"
                                             @"    parent = <NSObject: %p>\n"
                                             @"     child = @{@\"hi\": @\"lo\"}>", person, [person.siblings firstObject], parent];
            expect(person.description).to(contain(expectedDescription));
        });

        it(@"should have a debug description be the same as the description", ^{
            expect(person.debugDescription).to(contain(person.description));
        });

        it(@"should pretty print objective-c containers", ^{
            JKVCollections *container = [[JKVCollections alloc] initWithItems:@[@{@"hi": [NSSet setWithArray:@[@"lo", @"what up"]],
                                                                                  @"some": @"value"}]
                                                                        pairs:@{@"items": @[@{@"good": @"eats"},
                                                                                            @1],
                                                                                @"place": [NSURL URLWithString:@"http://google.com"]}];
            NSString *expectedDescription = [NSString stringWithFormat:
                                             @"<JKVCollections: %p\n"
                                             @" items = @[@{@'some': @'value',\n"
                                             @"             @'hi': [NSSet setWithArray:@[@'what up',\n"
                                             @"                                          @'lo']]}]\n"
                                             @" pairs = @{@'place': [NSURL URLWithString:@'http://google.com'],\n"
                                             @"           @'items': @[@{@'good': @'eats'},\n"
                                             @"                       1]}>", container];
            expectedDescription = [expectedDescription stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            expect(container.description).to(equal(expectedDescription));
        });
    });

    describe(@"equality", ^{
        context(@"when all properties are equivalent in value", ^{
            it(@"should be equal", ^{
                expect(person).to(equal(otherPerson));
            });

            it(@"should have the same hash code", ^{
                expect(@(person.hash)).to(equal(@(otherPerson.hash)));
            });

            it(@"should behave as the same value in a set", ^{
                expect(@([[NSSet setWithArray:@[person, otherPerson]] count])).to(equal(@1));
            });

            it(@"should be equal to mutable variant", ^{
                expect(person).to(equal([person mutableCopy]));
            });

            it(@"should have no diff", ^{
                expect([person differenceToObject:otherPerson]).to(beEmpty());
            });
        });

        context(@"when comparing to another class", ^{
            it(@"should not be equal", ^{
                expect(person).toNot(equal(@1));
            });

            it(@"should have class-type diff", ^{
                expect([person differenceToObject:@1]).to(equal(@{@"class": @[[JKVPerson class], [@1 class]]}));
            });
        });

        context(@"when the (weak) parent property is not equivalent in value", ^{
            beforeEach(^{
                otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                          lastName:person.lastName
                                                               age:person.age
                                                           married:person.married
                                                            height:person.height
                                                            parent:@"foo"
                                                          siblings:person.siblings
                                                             child:person.child];
            });

            it(@"should be equal", ^{
                expect(person).to(equal(otherPerson));
            });

            it(@"should have no diff", ^{
                expect([person differenceToObject:otherPerson]).to(beEmpty());
            });
        });

        context(@"when multiple properties are not equal", ^{
            beforeEach(^{
                otherPerson = [[JKVPerson alloc] initWithFirstName:nil
                                                          lastName:@"Pizza"
                                                               age:person.age
                                                           married:person.married
                                                            height:person.height
                                                            parent:parent
                                                          siblings:person.siblings
                                                             child:person.child];
            });

            it(@"should produce a diff of the properties that are different", ^{
                expect([person differenceToObject:otherPerson]).to(equal(@{@"firstName": @[person.firstName, [NSNull null]],
                                                                           @"lastName": @[person.lastName, @"Pizza"]}));
            });
        });

        void (^itShouldNotEqualWhen)(NSString *, NSString *, void(^)()) = ^(NSString *name, NSString *fieldName, void(^mutator)()) {
            context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                beforeEach(^{
                    mutator();
                });

                it(@"should not be equal", ^{
                    expect(person).toNot(equal(otherPerson));
                });

                it(@"should produce a diff of that property that is different", ^{
                    id originalValue = [person valueForKey:fieldName];
                    id mutatedValue = [otherPerson valueForKey:fieldName];
                    expect([person differenceToObject:otherPerson]).to(equal(@{fieldName: @[originalValue ?: [NSNull null],
                                                                                            mutatedValue ?: [NSNull null]]}));
                });
            });
        };

        itShouldNotEqualWhen(@"value's NSObject property is nil", @"firstName", ^{
            person = [[JKVPerson alloc] initWithFirstName:nil
                                                 lastName:person.lastName
                                                      age:person.age
                                                  married:person.married
                                                   height:person.height
                                                   parent:parent
                                                 siblings:person.siblings
                                                    child:person.child];
        });

        itShouldNotEqualWhen(@"age", @"age", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                      lastName:person.lastName
                                                           age:18
                                                       married:person.married
                                                        height:person.height
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
        });
        itShouldNotEqualWhen(@"firstName", @"firstName", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:@"James"
                                                      lastName:person.lastName
                                                           age:person.age
                                                       married:person.married
                                                        height:person.height
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
        });
        itShouldNotEqualWhen(@"lastName", @"lastName", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                      lastName:@"Appleseed"
                                                           age:person.age
                                                       married:person.married
                                                        height:person.height
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
        });
        itShouldNotEqualWhen(@"married", @"married", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                      lastName:person.lastName
                                                           age:person.age
                                                       married:NO
                                                        height:person.height
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
        });

        itShouldNotEqualWhen(@"height", @"height", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                      lastName:person.lastName
                                                           age:person.age
                                                       married:person.married
                                                        height:2.2
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
        });

        itShouldNotEqualWhen(@"child", @"child", ^{
            otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                      lastName:person.lastName
                                                           age:person.age
                                                       married:person.married
                                                        height:person.height
                                                        parent:parent
                                                      siblings:person.siblings
                                                         child:person.child];
            otherPerson.child = @"FOO";
        });
    });

    describe(@"NSSecureCoding", ^{
        __block JKVBasicValue *deserializedValue;
        __block NSMutableData *data;
        __block NSKeyedUnarchiver *unarchiver;

        beforeEach(^{
            data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:@"bad" forKey:@"number"];
            [archiver finishEncoding];

            unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        });

        afterEach(^{
            [unarchiver finishDecoding];
        });

        it(@"should support secure coding", ^{
            expect(@([JKVPerson supportsSecureCoding])).to(beTruthy());
        });

        context(@"when secure coding is required", ^{
            beforeEach(^{
                unarchiver.requiresSecureCoding = YES;
            });

            it(@"should raise exception if decoding a bad value", ^{
                BOOL raisedException = NO;
                @try {
                    deserializedValue = [[JKVBasicValue alloc] initWithCoder:unarchiver];
                } @catch (NSException *exception) {
                    raisedException = YES;
                    expect(exception).to(equal([NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Failed to unarchive 'number' as 'NSNumber'" userInfo:nil]));
                }
                expect(@(raisedException)).to(beTruthy());
            });
        });

        context(@"when secure coding is not required", ^{
            beforeEach(^{
                unarchiver.requiresSecureCoding = NO;
            });

            it(@"should not raise exception if decoding a bad value", ^{
                expectAction(^{
                    deserializedValue = [[JKVBasicValue alloc] initWithCoder:unarchiver];
                }).toNot(raiseException());
            });
        });
    });

    describe(@"NSCoding", ^{
        __block JKVPerson *parentPerson;
        __block JKVPerson *deserializedPerson;
        __block NSMutableData *data;

        beforeEach(^{
            data = [NSMutableData data];
            parentPerson = [[JKVPerson alloc] initWithFixtureData];
            person.parent = parentPerson;
            parentPerson.child = person;
        });

        context(@"conditional coding", ^{
            beforeEach(^{
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:parentPerson];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedPerson = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            });

            it(@"should have its child.parent encoded", ^{
                expect(deserializedPerson).to(equal(parentPerson));
                expect(deserializedPerson.child).to(equal(person));
                expect(@([deserializedPerson.child parent] == deserializedPerson)).to(beTruthy());
            });
        });

        context(@"Keyed Coding", ^{
            beforeEach(^{
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:person];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedPerson = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            });

            it(@"should support serialization", ^{
                expect(deserializedPerson).to(equal(person));
            });
        });

        context(@"Non-Keyed Coding", ^{
            // iOS doesn't support NSArchiver
            context(@"with an archiver", ^{
                __block KeyedArchiver *archiver;

                beforeEach(^{
                    archiver = [[KeyedArchiver alloc] initForWritingWithMutableData:data];
                    archiver.allowsKeyedCoding = NO;
                });

                afterEach(^{
                    [archiver finishEncoding];
                });

                it(@"should raise an exception", ^{
                    @try {
                        [person encodeWithCoder:archiver];
                        expect(@NO).to(beTruthy()); // always fail
                    } @catch (NSException *exception) {
                        expect(exception).to(equal([NSException exceptionWithName:NSInvalidArchiveOperationException reason:@"Only Keyed-Archivers are supported" userInfo:nil]));
                    }
                });
            });

            // iOS doesn't support NSUnarchiver
            context(@"with an unarchiver", ^{
                __block KeyedUnarchiver *unarchiver;

                beforeEach(^{
                    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    [archiver encodeObject:person];
                    [archiver finishEncoding];

                    unarchiver = [[KeyedUnarchiver alloc] initForReadingWithData:data];
                    unarchiver.allowsKeyedCoding = NO;
//                    spy_on(unarchiver);
//                    unarchiver stub_method(@selector(allowsKeyedCoding)).and_return(NO);
                });

                afterEach(^{
                    [unarchiver finishDecoding];
                });

                it(@"should raise an exception", ^{
                    @try {
                        deserializedPerson = [[JKVPerson alloc] initWithCoder:unarchiver];
                        expect(@NO).to(beTruthy()); // always fails
                    } @catch (NSException *exception) {
                        expect(exception).to(equal([NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Only Keyed-Unarchivers are supported" userInfo:nil]));
                    }
                });
            });
        });
    });

    describe(@"NSCopying", ^{
        __block JKVPerson *clonedPerson;
        beforeEach(^{
            clonedPerson = [person copy];
        });

        it(@"should return the same instance", ^{
            expect(@(clonedPerson == person)).to(beTruthy());
        });
    });

    describe(@"NSMutableCopying", ^{
        __block JKVPerson *clonedPerson;

        beforeEach(^{
            clonedPerson = [person mutableCopy];
        });

        it(@"should support copying", ^{
            expect(@(clonedPerson != person)).to(beTruthy());
            expect(clonedPerson).to(equal(person));
        });

        it(@"should be a mutable class variant", ^{
            expect(clonedPerson).to(beAnInstanceOf([JKVMutablePerson class]));
        });

        void (^itShouldRecursivelyCopy)(NSString *, id (^)(id)) = ^(NSString *name, id (^getter)(id obj)) {
            it([NSString stringWithFormat:@"should recursively copy %@", name], ^{
                expect(@(getter(person) == getter(clonedPerson))).to(beFalsy());
                expect(getter(person)).to(equal(getter(clonedPerson)));
            });
        };

        it(@"should preserve the weak properties", ^{
            expect(@(clonedPerson.parent == parent)).to(beTruthy());
        });

        it(@"should copy items in arrays", ^{
            expect(@([clonedPerson.siblings firstObject] != [person.siblings firstObject])).to(beTruthy());
        });

        it(@"should copy values in dictionaries", ^{
            expect(clonedPerson.child).toNot(beNil());
            for (NSInteger i=0; i<[clonedPerson.child count]; i++) {
                expect(@([clonedPerson.child allValues][i] != [person.child allValues][i])).to(beTruthy());
            }
        });

        itShouldRecursivelyCopy(@"firstName", ^id(JKVPerson *p){ return p.firstName; });
        itShouldRecursivelyCopy(@"lastName", ^id(JKVPerson *p){ return p.lastName; });
    });

    describe(@"type encoding", ^{
        __block JKVTypeContainer *box;
        __block JKVTypeContainer *otherBox;
        beforeEach(^{
            box = [[JKVTypeContainer alloc] initWithPresetData];
            otherBox = [[JKVTypeContainer alloc] initWithPresetData];
        });

        it(@"should support various types for encoding", ^{
            expect(box).to(equal(otherBox));
        });

        describe(@"NSCoding", ^{
            __block JKVTypeContainer *deserializedBox;

            beforeEach(^{
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                [archiver encodeObject:box];
                [archiver finishEncoding];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                deserializedBox = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            });

            it(@"should support serialization", ^{
                expect(deserializedBox).to(equal(box));
            });
        });
    });

    describe(@"collections that are properties", ^{
        __block JKVCollections *collections;
        beforeEach(^{
            collections = [[JKVCollections alloc] initWithItems:@[@1] pairs:@{@"A":@"B"}];
        });

        it(@"should support equality for cloned objects", ^{
            expect(collections).to(equal([collections copy]));
        });

        describe(@"mutable clone", ^{
            __block JKVMutableCollections *mutableCollections;
            beforeEach(^{
                mutableCollections = [collections mutableCopy];
            });

            it(@"should support mutation on the properties", ^{
                [mutableCollections.items addObject:@2];
                mutableCollections.pairs[@"C"] = @"D";
                expect(mutableCollections.items).to(equal(@[@1, @2]));
                expect(mutableCollections.pairs).to(equal(@{@"A": @"B", @"C": @"D"}));
            });

            it(@"should support equality for mutable cloned objects", ^{
                expect(collections).to(equal(mutableCollections));
            });
        });
    });

    describe(@"operating on a subset of properties", ^{
        __block JKVRestrictedObject *restrictedObject;
        __block id lastReader, lastWriter;
        beforeEach(^{
            restrictedObject = [[JKVRestrictedObject alloc] initWithPresetData];
            restrictedObject.lastReader = lastReader = [NSObject new];
            restrictedObject.lastWriter = lastWriter = [NSObject new];
        });

        describe(@"equality", ^{
            __block JKVRestrictedObject *otherObject;
            beforeEach(^{
                otherObject = [[JKVRestrictedObject alloc] initWithPresetData];
            });

            void (^itShouldNotEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
                context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                    it(@"should not be equal", ^{
                        mutator();
                        expect(restrictedObject).toNot(equal(otherObject));
                    });
                });
            };

            void (^itShouldEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
                context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                    it(@"should be equal", ^{
                        mutator();
                        expect(restrictedObject).to(equal(otherObject));
                    });
                });
            };

            itShouldEqualWhen(@"accessCount", ^{ otherObject.accessCount = @42; });
            itShouldEqualWhen(@"source", ^{ otherObject.source = @"Barney"; });
            itShouldEqualWhen(@"lastReader", ^{ otherObject.lastWriter = @"John"; });
            itShouldEqualWhen(@"lastWriter", ^{ otherObject.lastWriter = @"Doe"; });
            itShouldNotEqualWhen(@"accessLevel", ^{ otherObject.accessLevel = JKVAccessLevelAdmin; });
            itShouldNotEqualWhen(@"name", ^{ otherObject.name = @"Foobar"; });
        });

        describe(@"NSCopying", ^{
            __block JKVRestrictedObject *clonedObject;
            beforeEach(^{
                clonedObject = [restrictedObject copy];
            });

            it(@"should only clone the identity properties and the assign properties specified", ^{
                expect(clonedObject).to(equal(restrictedObject));
                expect(clonedObject.accessCount).to(beNil());
                expect(clonedObject.source).to(beNil());
                expect(clonedObject.lastReader).to(beNil());
                expect(@(clonedObject.lastWriter == lastWriter)).to(beTruthy());
            });
        });

        describe(@"NSMutableCopying", ^{
            __block JKVRestrictedObject *clonedObject;
            beforeEach(^{
                clonedObject = [restrictedObject mutableCopy];
            });

            it(@"should only clone the identity properties and the assign properties specified", ^{
                expect(clonedObject).to(equal(restrictedObject));
                expect(clonedObject.accessCount).to(beNil());
                expect(clonedObject.source).to(beNil());
                expect(clonedObject.lastReader).to(beNil());
                expect(@(clonedObject.lastWriter == lastWriter)).to(beTruthy());
            });
        });
    });
});

describe(@"JKVValue (Concurrency)", ^{
    __block dispatch_queue_t queue;
    __block dispatch_group_t group;

    beforeEach(^{
        [JKVClassInspector clearInstanceCache];
        queue = dispatch_queue_create("net.jeffhui.jkvvalue", DISPATCH_QUEUE_CONCURRENT);
        group = dispatch_group_create();
    });

    it(@"should not crash when used independently across threads", ^{
        NSUInteger numberOfTasks = 1000;
        for (NSUInteger i = 0; i < numberOfTasks; i++) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                [NSThread sleepForTimeInterval:(numberOfTasks - i) / (double)numberOfTasks];
                JKVPerson *person = [[JKVPerson alloc] initWithFirstName:@"John"
                                                                lastName:@"Doe"
                                                                     age:28
                                                                 married:YES
                                                                  height:60.8
                                                                  parent:nil
                                                                siblings:@[[[JKVMutablePerson alloc] initWithFixtureData]]
                                                                   child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
                JKVPerson *otherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                                     lastName:person.lastName
                                                                          age:person.age
                                                                      married:person.married
                                                                       height:person.height
                                                                       parent:nil
                                                                     siblings:@[[[JKVMutablePerson alloc] initWithFixtureData]]
                                                                        child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
                JKVPerson *anotherPerson = [[JKVPerson alloc] initWithFirstName:person.firstName
                                                                       lastName:person.lastName
                                                                            age:person.age
                                                                        married:person.married
                                                                         height:0
                                                                         parent:nil
                                                                       siblings:@[[[JKVMutablePerson alloc] initWithFixtureData]]
                                                                          child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];

                expect(person).to(equal(otherPerson));
                expect(@([person hash])).to(equal(@([otherPerson hash])));
                expect(person).toNot(equal(anotherPerson));
                dispatch_group_leave(group);
            });
        }

        BOOL timedOut = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        expect(@(timedOut)).to(beFalsy());
    });
});

QuickSpecEnd
