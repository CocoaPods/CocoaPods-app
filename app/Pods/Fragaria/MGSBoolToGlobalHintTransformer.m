//
//  MGSBoolToGlobalHintTransformer.m
//  Fragaria
//
//  Created by Jim Derry on 3/25/15.
//
//

#import "MGSBoolToGlobalHintTransformer.h"

@implementation MGSBoolToGlobalHintTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}


+ (BOOL)allowsReverseTransformation
{
	return NO;
}


- (id)transformedValue:(id)value
{
	if (value && [value boolValue])
	{
		return NSLocalizedStringFromTableInBundle(@"Items in bold affect all of your views.", nil, [NSBundle bundleForClass:[self class]], @"Hint explaining why certain items are bold.");
	}
	
	return nil;
}

@end
