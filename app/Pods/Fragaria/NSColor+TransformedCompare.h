//
//  NSColor+TransformedCompare.h
//  Fragaria
//
//  Created by Jim Derry on 3/23/15.
//
//

#import <Foundation/Foundation.h>


/** The MGSTransformCompare category allows comparison of NSColors after
 *  transformation by an NSValueTransformer.*/
@interface NSColor (MGSTransformedCompare)


/** Compares the objects produced by the specified value transformer from this
 *  color and the specified color, and returns YES if they are equal.
 *  @param colour Object to compare with.
 *  @param transf Name of the value transformer to be used. */
- (BOOL)mgs_isEqualToColor:(NSColor *)colour transformedThrough:(NSString*)transf;


@end
