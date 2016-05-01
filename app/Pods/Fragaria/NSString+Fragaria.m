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
    NSCharacterSet *nl;
    unichar chr;
    
    pos = 0;
    nl = [NSCharacterSet newlineCharacterSet];
    for (i=0; i<c; i++) {
        chr = [self characterAtIndex:i];
        if (chr == '\t') {
            if (tabwidth) {
                phase = pos % tabwidth;
                pos += tabwidth - phase;
            }
        } else if ([nl characterIsMember:chr])
            pos = NSUIntegerMax;
        else
            pos++;
    }
    return pos;
}


- (NSUInteger)mgs_characterInColumn:(NSUInteger)c tabWidth:(NSUInteger)tabwidth
{
    NSUInteger i, len, l, r, phase;
    NSCharacterSet *nl;
    unichar chr;
    
    r = 0;
    nl = [NSCharacterSet newlineCharacterSet];
    len = self.length;
    for (i=0; i<len; i++) {
        l = r;
        chr = [self characterAtIndex:i];
        if (chr == '\t') {
            if (tabwidth) {
                phase = r % tabwidth;
                r += tabwidth - phase;
            }
        } else if ([nl characterIsMember:chr])
            return i;
        else
            r++;
        if (l <= c && c < r)
            return i;
    }
    return NSNotFound;
}


- (NSRange)mgs_lineRangeForCharacterIndex:(NSUInteger)i
{
    if (i <= self.length)
        return [self lineRangeForRange:NSMakeRange(i, 0)];
    return NSMakeRange(NSNotFound, 0);
}


@end
