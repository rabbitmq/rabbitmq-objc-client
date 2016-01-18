@import Quick;
@import Nimble;
@import JKVValue;
#import "JKVPerson.h"

QuickSpecBegin(JKVObjectPrinterSpec)

describe(@"JKVObjectPrinter", ^{
    __block NSArray *array;
    __block NSDictionary *dictionary;
    __block NSSet *set;

    beforeEach(^{
        array = @[[[JKVPerson alloc] initWithFixtureData]];
        dictionary = @{@"key": [[JKVPerson alloc] initWithFixtureData]};
        set = [NSSet setWithArray:@[[[JKVPerson alloc] initWithFixtureData]]];
    });

    context(@"without swizzling", ^{
        beforeEach(^{
            [JKVObjectPrinter unswizzleContainers];
        });

        it(@"should display the default 'escaped' description", ^{
            expect([array description]).to(contain(@"\\n"));
            expect([dictionary description]).to(contain(@"\\n"));
            expect([set description]).to(contain(@"{("));
        });
    });

    context(@"with swizzling", ^{
        beforeEach(^{
            [JKVObjectPrinter swizzleContainers];
        });

        afterEach(^{
            [JKVObjectPrinter unswizzleContainers];
        });

        it(@"should display the custom description", ^{
            expect([array description]).toNot(contain(@"\\n"));
            expect([dictionary description]).toNot(contain(@"\\n"));
            expect([set description]).toNot(contain(@"{("));
        });
    });
});

QuickSpecEnd
