@import Quick;
@import Nimble;
#import "JKVFactory.h"
#import "JKVPersonFactory.h"
#import "JKVPerson.h"

QuickSpecBegin(JKVFactorySpec)

describe(@"JKVFactory", ^{
    __block JKVFactory *factory;
    __block JKVPerson *person;

    void (^itShouldBeAPersonObjectWithNonNilValues)() = ^{
        context(@"(behaves like a person object with non-nil values)", ^{
            it(@"should return an instance of the given object", ^{
                expect(person).to(beAnInstanceOf([JKVPerson class]));
            });

            it(@"should generate a person with non-nil values for strong properties", ^{
                expect(person.firstName).to(equal(@"firstName"));
                expect(person.lastName).toNot(beNil());
                expect(@(person.age)).to(equal(@1));
                expect(@(person.married)).to(beTruthy());
                expect(@(person.height)).to(equal(@1.0));
                expect(person.child).toNot(beNil());
            });

            it(@"should leave weak properties nil", ^{
                expect(person.parent).to(beNil());
            });
        });
    };

    void (^itShouldBehaveLikeAPersonObjectWithModifiedDefaults)() = ^{
        context(@"(behaves like a person object with modified defaults)", ^{
            it(@"should return an instance of the given object", ^{
                expect(person).to(beAnInstanceOf([JKVPerson class]));
            });

            it(@"should use the provided values, falling back to defaults", ^{
                expect(person.firstName).to(equal(@"John"));
                expect(@(person.age)).to(equal(@42));

                expect(person.lastName).to(equal(@"lastName"));
                expect(@(person.married)).to(beTruthy());
                expect(@(person.height)).to(equal(@1.0));
                expect(person.child).to(beNil());
                expect(person.parent).to(beNil());
            });
        });
    };

    void (^itShouldBehaveLikeAPersonFactoryInstance)() = ^{
        context(@"(behaves like a person factory instance)", ^{
            describe(@"building an object", ^{
                beforeEach(^{
                    person = [factory object];
                });

                itShouldBeAPersonObjectWithNonNilValues();
            });

            describe(@"building an object with custom values factory", ^{
                beforeEach(^{
                    person = [[factory factoryWithProperties:@{@"firstName": @"John",
                                                               @"age": @42,
                                                               @"child": [NSNull null]}] object];
                });

                itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
            });

            describe(@"building an object with custom values", ^{
                beforeEach(^{
                    person = [factory objectWithProperties:@{@"firstName": @"John",
                                                             @"age": @42,
                                                             @"child": [NSNull null]}];
                });

                itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
            });

            describe(@"building an object with nested custom factories", ^{
                beforeEach(^{
                    person = [[factory
                               factoryWithProperties:@{@"firstName": @"John",
                                                       @"age": @42,
                                                       @"child": [NSNull null]}]
                              objectWithProperties:@{@"firstName": @"James"}];
                });

                it(@"should have the latest factory properties", ^{
                    expect(person.firstName).to(equal(@"James"));
                    expect(@(person.age)).to(equal(@42));
                });
            });

        });
    };

    describe(@"generic factory", ^{
        beforeEach(^{
            factory = [JKVFactory factoryForClass:[JKVPerson class]];
        });

        itShouldBehaveLikeAPersonFactoryInstance();

        describe(@"+buildObject", ^{
            it(@"should raise an exception", ^{
                expectAction(^{ [JKVFactory buildObject]; }).to(raiseException());
            });
        });

        describe(@"+buildObjectWithProperties", ^{
            it(@"should raise an exception", ^{
                expectAction(^{ [JKVFactory buildObjectWithProperties:@{}]; }).to(raiseException());
            });
        });
    });

    describe(@"customized factory", ^{
        beforeEach(^{
            factory = [JKVPersonFactory new];
        });

        itShouldBehaveLikeAPersonFactoryInstance();

        describe(@"building an object without a factory instance", ^{
            beforeEach(^{
                person = [JKVPersonFactory buildObject];
            });

            itShouldBeAPersonObjectWithNonNilValues();
        });

        describe(@"building a custom object without a factory instance", ^{
            beforeEach(^{
                person = [JKVPersonFactory buildObjectWithProperties:@{@"firstName": @"John", @"age": @42, @"child": [NSNull null]}];
            });

            itShouldBehaveLikeAPersonObjectWithModifiedDefaults();
        });
    });
});

QuickSpecEnd
