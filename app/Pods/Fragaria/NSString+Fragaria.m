//
//  NSString+Fragaria.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 16/05/15.
//
//

#import "NSString+Fragaria.h"


@implementation NSString (Fragaria)


/*
 * - mgs_columnOfCharacter:tabWidth:
 */
- (NSUInteger)mgs_columnOfCharacter:(NSUInteger)c tabWidth:(NSUInteger)tabwidth
{
    NSUInteger i, pos, phase;
    
    pos = 0;
    for (i=0; i<c; i++) {
        if ([self characterAtIndex:i] == '\t') {
            phase = pos % tabwidth;
            pos += tabwidth - phase;
        } else
            pos++;
    }
    return pos;
}


@end
