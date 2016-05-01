//
//  NSSet+Fragaria.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 06/03/16.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>


/** This private category adds an utility initializer to NSSet. */

@interface NSSet (Fragaria)


/** Returns an NSSet of those NSNumbers that are indexes of the specified 
 *  index set.
 *  @param is An index set. */
- (NSSet *)mgs_initWithIndexSet:(NSIndexSet *)is;

@end
