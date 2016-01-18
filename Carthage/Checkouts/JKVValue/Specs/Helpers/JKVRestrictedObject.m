#import "JKVRestrictedObject.h"

@implementation JKVRestrictedObject

- (id)initWithPresetData
{
    self = [super init];
    if (self) {
        self.accessLevel = JKVAccessLevelGeneral;
        self.name = @"Public Access";
        self.accessCount = @2;
        self.source = @"Door";
    }
    return self;
}

- (NSArray *)JKV_propertyNamesForIdentity
{
    return @[@"accessLevel", @"name"];
}

- (NSArray *)JKV_propertyNamesToAssignCopy
{
    return @[@"lastWriter"];
}

@end
