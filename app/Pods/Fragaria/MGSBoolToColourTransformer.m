//
//  MGSPropertyAvailableTransformer.m
//  Fragaria
//
//  Created by Jim Derry on 3/15/15.
//
//

#import "MGSBoolToColourTransformer.h"

@implementation MGSBoolToColourTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}


+ (BOOL)allowsReverseTransformation
{
    return NO;
}


- (id)transformedValue:(id)value
{
//    return [NSColor controlTextColor];
    return [value boolValue] == YES ? [NSColor controlTextColor] : [[NSColor controlTextColor] colorWithAlphaComponent:0.25];
}

@end
