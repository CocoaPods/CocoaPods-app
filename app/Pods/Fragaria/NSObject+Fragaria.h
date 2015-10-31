//
//  NSObject+Fragaria.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 29/05/15.
//
//

#import <Foundation/Foundation.h>


/** 
 *  This category adds miscellaneous methods to NSObject, to be used only
 *  internally to Fragaria.
 */

@interface NSObject (Fragaria)


/** If the specified property is bound to an object, set the given value on
 *  the bound object.
 *  @discussion For details on why this is necessary, see
 *  http://www.tomdalling.com/blog/cocoa/implementing-your-own-cocoa-bindings/
 *  @param value The value to be set on the bound object.
 *  @param binding The property of this object which is to be propagated. */
- (void)mgs_propagateValue:(id)value forBinding:(NSString*)binding;


@end
