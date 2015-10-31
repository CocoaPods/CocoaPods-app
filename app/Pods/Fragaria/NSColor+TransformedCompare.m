//
//  NSColor+TransformedCompare.h
//  Fragaria
//
//  Created by Jim Derry on 3/23/15.
//
//

#import "NSColor+TransformedCompare.h"
#import "MGSColourToPlainTextTransformer.h"


@implementation NSColor (MGSTransformedCompare)


/*
 * - mgs_isEqualToColor:transformedThrough:
 */
- (BOOL)mgs_isEqualToColor:(NSColor *)colour transformedThrough:(NSString*)tname
{
	NSValueTransformer *xformer = [NSValueTransformer valueTransformerForName:tname];

	id result1 = [xformer transformedValue:self];
	id result2 = [xformer transformedValue:colour];
	
    return [result1 isEqual:result2];
}


@end
