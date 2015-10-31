//
//  MGSFontToTextTransformer.m
//  Fragaria
//
//  Created by Jim Derry on 3/23/15.
//
//

#import "MGSColourToPlainTextTransformer.h"


@implementation MGSColourToPlainTextTransformer


/*
 * + transformedValueClass
 */
+ (Class)transformedValueClass
{
	return [NSColor class];
}


/*
 * + allowsReverseTransformation
 */
+ (BOOL)allowsReverseTransformation
{
	return YES;
}


/*
 * - transformedValue:
 */
- (id)transformedValue:(id)col
{
    NSColor *nc;
    NSMutableString *tmp;
    
    nc = [col colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (!nc) {
        NSLog(@"MGSStringFromColor: can't convert %@, returning red", col);
        return @"1.0 0.0 0.0";
    }
    
    tmp = [NSMutableString string];
    [tmp appendFormat:@"%lf %lf %lf", nc.redComponent, nc.greenComponent, nc.blueComponent];
    if (nc.alphaComponent != 1.0)
        [tmp appendFormat:@" %lf", nc.alphaComponent];
    
    return [tmp copy];
}


/*
 * - reverseTransformedValue:
 */
-(id)reverseTransformedValue:(id)str
{
    NSScanner *scan;
    CGFloat r, g, b, a;
    
    scan = [NSScanner scannerWithString:str];
    
    a = 1.0;
    if (!([scan scanDouble:&r] && [scan scanDouble:&g] && [scan scanDouble:&b])) {
        NSLog(@"MGSColorFromString: can't parse %@, returning red", str);
        return [NSColor redColor];
    }
    [scan scanDouble:&a];
    
    return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}


@end
