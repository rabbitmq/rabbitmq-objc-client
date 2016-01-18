#import "JKVMutableValue.h"

typedef NS_ENUM(NSUInteger, JKVAccessLevel) {
    JKVAccessLevelDenied = 0,
    JKVAccessLevelGeneral,
    JKVAccessLevelAdmin
};

@interface JKVRestrictedObject : JKVMutableValue

@property (assign, nonatomic) JKVAccessLevel accessLevel;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *accessCount;
@property (strong, nonatomic) NSString *source;
@property (weak, nonatomic) id lastReader;
@property (weak, nonatomic) id lastWriter;

- (id)initWithPresetData;

@end
