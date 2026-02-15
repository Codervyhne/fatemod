//
//  FateModMenu.h
//  Fate Mod - Modern iOS Mod Menu
//
//  Created for Animal Company
//  Version 1.0
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface FateModMenu : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

// UI Components
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *tabControl;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) UIPickerView *locationPicker;
@property (nonatomic, strong) UILabel *quantityLabel;
@property (nonatomic, strong) UIStepper *quantityStepper;
@property (nonatomic, strong) UITextField *searchField;

// Data
@property (nonatomic, strong) NSArray *availableItems;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic, strong) NSArray *presetLocations;
@property (nonatomic, strong) NSDictionary *locationCoordinates;
@property (nonatomic, assign) NSInteger currentTab;
@property (nonatomic, assign) NSInteger selectedItemIndex;
@property (nonatomic, assign) NSInteger spawnQuantity;
@property (nonatomic, assign) NSInteger selectedLocationIndex;

// Location settings
@property (nonatomic, assign) BOOL useCustomLocation;
@property (nonatomic, assign) float customX;
@property (nonatomic, assign) float customY;
@property (nonatomic, assign) float customZ;

// Game integration pointers
@property (nonatomic, assign) void *netPlayerClass;
@property (nonatomic, assign) void *prefabGeneratorClass;
@property (nonatomic, assign) void *gameManagerClass;
@property (nonatomic, assign) void *spawnItemMethod;
@property (nonatomic, assign) void *addMoneyMethod;
@property (nonatomic, assign) void *gameImage;

// IL2CPP Function pointers
@property (nonatomic, assign) void *(*il2cpp_class_from_name)(void *image, const char *namespaze, const char *name);
@property (nonatomic, assign) void *(*il2cpp_class_get_method_from_name)(void *klass, const char *name, int argsCount);
@property (nonatomic, assign) void *(*il2cpp_runtime_invoke)(void *method, void *obj, void **params, void **exc);
@property (nonatomic, assign) void *(*il2cpp_string_new)(const char *str);
@property (nonatomic, assign) void *(*il2cpp_class_get_field_from_name)(void *klass, const char *name);
@property (nonatomic, assign) void (*il2cpp_field_set_value)(void *obj, void *field, void *value);

// Initialization
- (BOOL)initializeIL2CPP;
- (BOOL)initializeGameClasses;
- (void *)getGameImage:(const char *)imageName;

@end