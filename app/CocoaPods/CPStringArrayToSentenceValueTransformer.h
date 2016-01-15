#import <Foundation/Foundation.h>

/// Allows us to go from ["thing", "other", "etc"] to:
/// "Thing, other & etc" or "Thing & other" or "Thing"
/// in the interface without having to write the glue code.

@interface CPStringArrayToSentenceValueTransformer : NSValueTransformer

@end
