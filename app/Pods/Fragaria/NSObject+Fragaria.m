//
//  NSObject+Fragaria.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 29/05/15.
//
//

#import "NSObject+Fragaria.h"


@implementation NSObject (Fragaria)


/*
 * - propagateValue:forBinding
 * http://www.tomdalling.com/blog/cocoa/implementing-your-own-cocoa-bindings/
 */
- (void)mgs_propagateValue:(id)value forBinding:(NSString*)binding
{
    NSDictionary *bindingInfo, *bindingOptions;
    NSValueTransformer* transformer;
    NSString* transformerName;
    id boundObject;
    NSString *boundKeyPath;
    
    NSParameterAssert(binding != nil);
    
    //WARNING: bindingInfo contains NSNull, so it must be accounted for
    bindingInfo = [self infoForBinding:binding];
    if (!bindingInfo)
        return; //there is no binding
    
    //apply the value transformer, if one has been set
    bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
    if (bindingOptions) {
        transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
        if (!transformer || (id)transformer == [NSNull null]) {
            transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
            if (transformerName && (id)transformerName != [NSNull null]) {
                transformer = [NSValueTransformer valueTransformerForName:transformerName];
            }
        }
        
        if (transformer && (id)transformer != [NSNull null]) {
            if ([[transformer class] allowsReverseTransformation]) {
                value = [transformer reverseTransformedValue:value];
            } else {
                NSLog(@"WARNING: binding \"%@\" has value transformer, but it "
                  "doesn't allow reverse transformations in %s", binding,
                  __PRETTY_FUNCTION__);
            }
        }
    }
    
    boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
    if (!boundObject || boundObject == [NSNull null]) {
        NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s",
          binding, __PRETTY_FUNCTION__);
        return;
    }
    
    boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
    if (!boundKeyPath || (id)boundKeyPath == [NSNull null]) {
        NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s",
          binding, __PRETTY_FUNCTION__);
        return;
    }
    
    [boundObject setValue:value forKeyPath:boundKeyPath];
}


@end
