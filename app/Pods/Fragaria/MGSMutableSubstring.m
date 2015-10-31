//
//  MGSMutableSubstring.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 15/05/15.
//
//

#import "MGSMutableSubstring.h"


@implementation MGSMutableSubstring {
    NSMutableString *storage;
    NSRange range;
}


- (instancetype)initWithRange:(NSRange)r ofSuperstring:(NSMutableString *)s
{
    self = [super init];
    
    storage = s;
    range = r;
    
    if (NSMaxRange(range) > [storage length])
        [NSException raise:NSRangeException format:@"Attempted to create a "
         "MGSMutableSubstring from an invalid range!"];
    
    return self;
}


+ (instancetype)substringInRange:(NSRange)r ofString:(NSMutableString *)s
{
    return [[[self class] alloc] initWithRange:r ofSuperstring:s];
}


- (NSUInteger)length
{
    return range.length;
}


- (unichar)characterAtIndex:(NSUInteger)index
{
    if (index >= range.length)
        [NSException raise:NSRangeException format:@"MGSMutableSubstring "
         " character at index %ld is out of bounds!", index];
    return [storage characterAtIndex:range.location + index];
}


- (NSRange)superstringRangeFromRange:(NSRange)aRange
{
    NSRange newRange;
    
    newRange = aRange;
    newRange.location += range.location;
    
    if (NSMaxRange(newRange) > NSMaxRange(range))
        newRange = NSMakeRange(NSNotFound, 0);
    return newRange;
}


- (NSRange)superstringRange
{
    return range;
}


- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange
{
    NSRange newRange;
    
    newRange = [self superstringRangeFromRange:aRange];
    if (newRange.location == NSNotFound)
        [NSException raise:NSRangeException format:@"Range %@ is out of "
         "bounds!", NSStringFromRange(aRange)];
    
    [storage getCharacters:buffer range:newRange];
}


- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
    NSRange myRange;
    NSInteger lengthDiff;
    
    myRange = [self superstringRangeFromRange:aRange];
    if (myRange.length == NSNotFound)
        [NSException raise:NSRangeException format:@"Range %@ is out of "
         "bounds!", NSStringFromRange(aRange)];
    
    lengthDiff = aString.length - myRange.length;
    [storage replaceCharactersInRange:myRange withString:aString];
    range.length += lengthDiff;
}


- (NSMutableString *)superstring
{
    return storage;
}


@end


@implementation NSMutableString (MutableSubstring)


- (NSArray *)enumerateMutableSubstringsFromRangeArray:(NSArray*)a usingBlock:
  (void (^)(MGSMutableSubstring *substring, BOOL *stop))b
{
    NSInteger offset;
    NSMutableArray *output;
    NSValue *rangeval;
    NSRange range;
    MGSMutableSubstring *tmp;
    BOOL stop;
    
    output = [NSMutableArray array];
    offset = stop = 0;
    
    for (rangeval in a) {
        range = [rangeval rangeValue];
        range.location += offset;
        tmp = [MGSMutableSubstring substringInRange:range ofString:self];
        b(tmp, &stop);
        
        offset += tmp.length - range.length;
        [output addObject:[NSValue valueWithRange:[tmp superstringRange]]];
        
        if (stop) break;
    }
    return [output copy];
}


- (void)enumerateMutableSubstringsOfLinesUsingBlock:(void (^)
  (MGSMutableSubstring *substring, BOOL *stop))b
{
    NSRange line;
    NSUInteger lineEnd;
    MGSMutableSubstring *tmp;
    BOOL stop;
    
    stop = 0;
    line = NSMakeRange(0, 0);
    
    while (NSMaxRange(line) < [self length]) {
        [self getLineStart:NULL end:&lineEnd contentsEnd:NULL forRange:line];
        line.length = lineEnd - line.location;
        
        tmp = [MGSMutableSubstring substringInRange:line ofString:self];
        b(tmp, &stop);
        if (stop) break;
        
        line.location = NSMaxRange([tmp superstringRange]);
        line.length = 0;
    }
}


- (MGSMutableSubstring *)mutableSubstringByLeftTrimmingCharactersFromSet:
  (NSCharacterSet *)cs
{
    NSUInteger i;
    NSRange range;
    
    i = 0;
    while (i < [self length] && [cs characterIsMember:[self characterAtIndex:i]])
        i++;
    range = NSMakeRange(i, [self length] - i);
    
    return [MGSMutableSubstring substringInRange:range ofString:self];
}


@end


