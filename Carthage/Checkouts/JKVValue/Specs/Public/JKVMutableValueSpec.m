@import Quick;
@import Nimble;
#import "JKVMutablePerson.h"
#import "JKVPerson.h"
#import "JKVMutableCollections.h"


QuickSpecBegin(JKVMutableValueSpec)

describe(@"JKVMutableValue", ^{
    __block JKVMutablePerson *person, *otherPerson;
    __block id parent;

    beforeEach(^{
        parent = [NSObject new];
        person = [[JKVMutablePerson alloc] initWithFirstName:@"John"
                                                    lastName:@"Doe"
                                                         age:28
                                                     married:YES
                                                      height:60.8
                                                      parent:parent
                                                    siblings:@[[NSMutableString stringWithString:@"yolo"]]
                                                       child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
        otherPerson = [[JKVMutablePerson alloc] initWithFirstName:@"John"
                                                         lastName:@"Doe"
                                                              age:28
                                                          married:YES
                                                           height:60.8
                                                           parent:parent
                                                         siblings:@[[NSMutableString stringWithString:@"yolo"]]
                                                            child:@{[NSMutableString stringWithFormat:@"hi"]: [NSMutableString stringWithFormat:@"lo"]}];
    });

    it(@"should have a custom description", ^{
        NSString *expectedDescription = [NSString stringWithFormat:
                                         @"<JKVMutablePerson: %p\n"
                                         @"     child = @{@\"hi\": @\"lo\"}\n"
                                         @" firstName = @\"John\"\n"
                                         @"  lastName = @\"Doe\"\n"
                                         @"       age = 28\n"
                                         @"   married = 1\n"
                                         @"    height = 60.8\n"
                                         @"    parent = <NSObject: %p>\n"
                                         @"  siblings = @[@\"yolo\"]>", person, parent];
        expect(person.description).to(contain(expectedDescription));
    });

    describe(@"equality", ^{
        context(@"when all properties are equivalent in value", ^{
            it(@"should be equal", ^{
                expect(person).to(equal(otherPerson));
            });

            it(@"should have the same hash code", ^{
                expect(@(person.hash)).to(equal(@(otherPerson.hash)));
            });

            it(@"should be equal to the immutable variant", ^{
                expect(person).to(equal([person copy]));
            });
        });

        context(@"when the (weak) parent property is not equivalent in value", ^{
            it(@"should be equal", ^{
                otherPerson.parent = nil;
                expect(person).to(equal(otherPerson));
            });
        });

        it(@"should not equal another object", ^{
            expect(person).toNot(equal((id)@1));
        });

        void (^itShouldNotEqualWhen)(NSString *, void(^)()) = ^(NSString *name, void(^mutator)()) {
            context([NSString stringWithFormat:@"when the %@ is not equivalent in value", name], ^{
                it(@"should not be equal", ^{
                    mutator();
                    expect(person).toNot(equal(otherPerson));
                });
            });
        };

        itShouldNotEqualWhen(@"age", ^{ otherPerson.age = 12; });
        itShouldNotEqualWhen(@"firstName", ^{ otherPerson.firstName = @"James"; });
        itShouldNotEqualWhen(@"lastName", ^{ otherPerson.firstName = @"Appleseed"; });
        itShouldNotEqualWhen(@"married", ^{ otherPerson.married = NO; });
        itShouldNotEqualWhen(@"height", ^{ otherPerson.height = 2; });
    });

    describe(@"NSCoding", ^{
        __block JKVMutablePerson *deserializedPerson;

        beforeEach(^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [person encodeWithCoder:archiver];
            [archiver finishEncoding];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            deserializedPerson = [[JKVMutablePerson alloc] initWithCoder:unarchiver];
            [unarchiver finishDecoding];
        });

        it(@"should support serialization", ^{
            expect(deserializedPerson).to(equal(person));
        });
    });

    describe(@"NSCopying", ^{
        __block JKVPerson *clonedPerson;

        beforeEach(^{
            clonedPerson = [person copy];
        });

        it(@"should support copying", ^{
            expect(@(clonedPerson != person)).to(beTruthy());
            expect(clonedPerson).to(equal(person));
        });

        void (^itShouldRecursivelyCopy)(NSString *, id (^)(id)) = ^(NSString *name, id (^getter)(id obj)) {
            it([NSString stringWithFormat:@"should recursively copy %@", name], ^{
                expect(@(getter(person) != getter(clonedPerson))).to(beTruthy());
                expect(getter(person)).to(equal(getter(clonedPerson)));
            });
        };

        it(@"should preserve the weak properties", ^{
            expect(@(clonedPerson.parent == parent)).to(beTruthy());
        });

        itShouldRecursivelyCopy(@"firstName", ^id(JKVPerson *p){ return p.firstName; });
        itShouldRecursivelyCopy(@"lastName", ^id(JKVPerson *p){ return p.lastName; });
    });

    describe(@"NSMutableCopying", ^{
        __block JKVMutablePerson *clonedPerson;

        beforeEach(^{
            clonedPerson = [person mutableCopy];
        });

        it(@"should support copying", ^{
            expect(@(clonedPerson != person)).to(beTruthy());
            expect(clonedPerson).to(equal(person));
        });

        void (^itShouldRecursivelyCopy)(NSString *, id (^)(id)) = ^(NSString *name, id (^getter)(id obj)) {
            it([NSString stringWithFormat:@"should recursively copy %@", name], ^{
                expect(@(getter(person) != getter(clonedPerson))).to(beTruthy());
                expect(getter(person)).to(equal(getter(clonedPerson)));
            });
        };

        it(@"should preserve the weak properties", ^{
            expect(@(clonedPerson.parent == parent)).to(beTruthy());
        });

        itShouldRecursivelyCopy(@"firstName", ^id(JKVMutablePerson *p){ return p.firstName; });
        itShouldRecursivelyCopy(@"lastName", ^id(JKVMutablePerson *p){ return p.lastName; });
    });

    context(@"collections that are properties", ^{
        __block JKVMutableCollections *collections;

        beforeEach(^{
            collections = [[JKVMutableCollections alloc] initWithItems:@[[NSMutableString stringWithString:@"hi"]]
                                                                 pairs:@{[NSMutableString stringWithString:@"A"]: [NSMutableString stringWithString:@"B"]}];
        });

        describe(@"copying", ^{
            it(@"should support equality for cloned objects", ^{
                expect(collections).to(equal([collections copy]));
            });
        });

        describe(@"mutableCopying", ^{
            it(@"should copy all values in collections", ^{
                expect(@([collections.items firstObject] != [[[collections mutableCopy] items] firstObject])).to(beTruthy());
                expect(@([[collections.pairs allValues] firstObject] != [[[[collections mutableCopy] pairs] allValues] firstObject])).to(beTruthy());
            });
            
            it(@"should support equality for mutable cloned objects", ^{
                expect(collections).to(equal([collections mutableCopy]));
            });
        });
    });
});

QuickSpecEnd
