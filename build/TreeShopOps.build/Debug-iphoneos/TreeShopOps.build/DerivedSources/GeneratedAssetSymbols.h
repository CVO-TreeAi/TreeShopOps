#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.treeshop.calculator.v2";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "TreeShopBlack" asset catalog color resource.
static NSString * const ACColorNameTreeShopBlack AC_SWIFT_PRIVATE = @"TreeShopBlack";

/// The "TreeShopBlue" asset catalog color resource.
static NSString * const ACColorNameTreeShopBlue AC_SWIFT_PRIVATE = @"TreeShopBlue";

/// The "TreeShopGreen" asset catalog color resource.
static NSString * const ACColorNameTreeShopGreen AC_SWIFT_PRIVATE = @"TreeShopGreen";

#undef AC_SWIFT_PRIVATE
