//
//  NSTextStorage+Fragaria.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 12/12/15.
//
//

#import "NSTextStorage+Fragaria.h"
#import "NSString+Fragaria.h"
#import <objc/runtime.h>


/* MGSTextStorageLineNumberData is a helper class that tells NSTextStorage when
 * it has been edited. It sounds ridicuolous, but consider that:
 *  - overriding a method is not allowed in a category
 *  - subclassing NSTextStorage *is not* an option for obvious reasons (the
 *    application owns NSTextStorage, and forcing the world to give us only
 *    instances of MGSLittleSnowflakeTextStorage is impossible)
 *  - method swizzling is unfeasible because NSTextStorage is a class cluster,
 *    and some random class in the cluster might override the method you
 *    swizzle, canceling it out. */

@interface MGSTextStorageLineNumberData : NSObject
{
    @public
    NSUInteger firstInvalidCharacter;
    NSMutableArray *firstCharacterOfEachLine;
    
    NSUInteger lineCountGuess;
    /* lineCountGuess == NSNotFound also means that lastEditedRange and
     * lastChangeInLength are invalid */
    NSRange lastEditedRange;
    NSInteger lastChangeInLength;
    /* The character range starting at firstInvalidCharacter and ending at
     * previousInvalidCharacter is the range where the indices in
     * firstCharacterOfEachLine are still reflecting the situation of the
     * text contents before the last edit. */
    NSUInteger previousInvalidCharacter;
}

@end


@implementation MGSTextStorageLineNumberData


- (instancetype)initWithTextStorage:(NSTextStorage *)ts
{
    NSNotificationCenter *nc;
    
    self = [super init];
    
    firstInvalidCharacter = 0;
    firstCharacterOfEachLine = [[NSMutableArray alloc] init];
    
    lineCountGuess = NSNotFound;
    
    nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(textStorageWillProcessEditing:)
      name:NSTextStorageWillProcessEditingNotification object:ts];
    
    return self;
}


- (void)textStorageWillProcessEditing:(NSNotification *)notification
{
    NSTextStorage *ts;
    
    ts = [notification object];
    previousInvalidCharacter = firstInvalidCharacter;
    firstInvalidCharacter = MIN(firstInvalidCharacter, ts.editedRange.location);
    
    if (lineCountGuess) {
        if (lastEditedRange.length == 0 && lastChangeInLength == 0) {
            lastEditedRange = ts.editedRange;
            lastChangeInLength = ts.changeInLength;
        } else {
            /* Merging edited ranges is difficult, so we give up. */
            lineCountGuess = NSNotFound;
        }
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end



const static void *MGSLineNumberData = &MGSLineNumberData;


@implementation NSTextStorage (Fragaria)


- (MGSTextStorageLineNumberData *)mgs_lineNumberData
{
    MGSTextStorageLineNumberData *lnd;
    
    if (!(lnd = objc_getAssociatedObject(self, MGSLineNumberData))) {
        lnd = [[MGSTextStorageLineNumberData alloc] initWithTextStorage:self];
        objc_setAssociatedObject(self, MGSLineNumberData, lnd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lnd;
}

/* maxc and maxl can be any valid or invalid character index.
 * This function caches all the lines up to and including the one which
 * contains the specified character, stopping early if the given line number
 * was reached. Empty new lines are special cased to appear as a phantom
 * character trailing the string. */
- (NSUInteger)mgs_cacheLineNumberDataUntilCharacter:(NSUInteger)maxc orLine:(NSUInteger)maxl
{
    MGSTextStorageLineNumberData *lnd = [self mgs_lineNumberData];
    NSMutableArray *fcla;
    NSUInteger i, l, len, e;
    NSString *s;
    NSRange lr;
    
    fcla = lnd->firstCharacterOfEachLine;
    len = self.length;
    
    if (lnd->firstInvalidCharacter > 0) {
        i = lnd->firstInvalidCharacter - 1;
        l = [self mgs_rowOfValidCharacter:i];
    } else
        i = l = 0;
    if ([fcla count] > l)
        [fcla removeObjectsInRange:NSMakeRange(l, [fcla count] - l)];
    
    s = [self string];
    lr = [s lineRangeForRange:NSMakeRange(i, 0)];
    while (maxc >= lr.location && maxl >= l) {
        [fcla addObject:@(lr.location)];
        i = NSMaxRange(lr);
        l++;
        if (i == len) {
            if (lr.length == 0) {
                /* Already handled last empty line */
                i++;
                break;
            } else {
                /* Check for last empty line special case */
                [s getLineStart:NULL end:NULL contentsEnd:&e forRange:lr];
                if (e != i)
                    lr = NSMakeRange(i, 0);
                else
                    break;
            }
        } else
            lr = [s lineRangeForRange:NSMakeRange(i, 0)];
    }
    lnd->previousInvalidCharacter = lnd->firstInvalidCharacter;
    lnd->firstInvalidCharacter = i;
    return l-1;
}


/* c must point to a character of self, or be equal to self.length */
- (NSUInteger)mgs_rowOfValidCharacter:(NSUInteger)c
{
    MGSTextStorageLineNumberData *lnd = [self mgs_lineNumberData];
    NSUInteger i, n;
    NSMutableArray *fcla;
    
    fcla = lnd->firstCharacterOfEachLine;
    n = [fcla count];
    
    i = [fcla indexOfObject:@(c) inSortedRange:NSMakeRange(0, n)
                    options:NSBinarySearchingInsertionIndex | NSBinarySearchingLastEqual
            usingComparator:^ NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
    
    if (i == n || ![[fcla objectAtIndex:i] isEqual:@(c)])
        i--;
    return i;
}


/* Getting the line count by querying the line number cache means that we
 * have to rebuild it until the end if it is outdated, and this is expensive.
 *   So we keep track of the last edit, and we just update a line number cache
 * by examining the range which was changed to determine how many lines were
 * added or deleted without iterating over the whole string.
 *   If more than one edit was made since the last call to mgs_lineCount, or if
 * we encounter an edit we can't get reliable information about, we give up and
 * rebuild the cache. 
 *   Note that CRLF is a bitch of a newline format to handle with this method
 * because we can't just assume people are nice... */
- (NSUInteger)mgs_lineCount
{
    MGSTextStorageLineNumberData *lnd = [self mgs_lineNumberData];
    NSRange er = lnd->lastEditedRange;
    NSInteger lc = lnd->lastChangeInLength;
    NSUInteger l0, l1, lcg;
    NSString *s;
    BOOL onlyRemoval, onlyInsertion;
    
    onlyRemoval = lc < 0 && er.length == 0;
    onlyInsertion = lc >= 0 && er.length == (NSUInteger)(lc);
    
    if (lnd->lineCountGuess == NSNotFound)
        goto fallback;
    
    if (onlyInsertion || onlyRemoval) {
        if (onlyInsertion && er.length > 0) {
            lcg = lnd->lineCountGuess;
            
            /* Did somebody (=our unit test) break a CRLF into a CR and a LF? */
            if (er.location > 0 && NSMaxRange(er) < self.length) {
                s = [self string];
                if ([s characterAtIndex:er.location-1] == '\r')
                    if ([s characterAtIndex:NSMaxRange(er)] == '\n')
                        lcg++;
            }
            
            l0 = [self mgs_rowOfMaybeInvalidCharacter:er.location];
            l1 = [self mgs_rowOfMaybeInvalidCharacter:NSMaxRange(er)];
            lnd->lineCountGuess = lcg + (l1 - l0);
            lnd->lastEditedRange = NSMakeRange(0, 0);
            lnd->lastChangeInLength = 0;
        } else if (onlyRemoval) {
            er.length = (-lc);
            
            /* Bail out if we do not have enough info about the previous state
             * of the string (we can't go back in time after the string is
             * edited and thus we get the past state by querying the outdated
             * parts of the cache) */
            if (!(lnd->firstInvalidCharacter <= er.location &&
                  NSMaxRange(er) < lnd->previousInvalidCharacter))
                goto fallback;
            
            /* Did somebody (=our unit test) recompose a CRLF into a CR and a LF? */
            if (er.location > 0 && er.location < self.length) {
                s = [self string];
                if ([s characterAtIndex:er.location-1] == '\r')
                    if ([s characterAtIndex:er.location] == '\n')
                        lnd->lineCountGuess--;
            }
            
            l0 = [self mgs_rowOfValidCharacter:er.location];
            l1 = [self mgs_rowOfValidCharacter:NSMaxRange(er)];
            [self mgs_cacheLineNumberDataUntilCharacter:er.location+1 orLine:NSUIntegerMax];
            lnd->lineCountGuess -= (l1 - l0);
            lnd->lastEditedRange = NSMakeRange(0, 0);
            lnd->lastChangeInLength = 0;
        }
        return lnd->lineCountGuess;
    }
    
fallback:
    lnd->lineCountGuess = [self mgs_rowOfMaybeInvalidCharacter:self.length] + 1;
    lnd->lastEditedRange = NSMakeRange(0, 0);
    lnd->lastChangeInLength = 0;
    return lnd->lineCountGuess;
}


- (NSUInteger)mgs_rowOfMaybeInvalidCharacter:(NSUInteger)c
{
    MGSTextStorageLineNumberData *lnd = [self mgs_lineNumberData];
    
    if (c == 0)
        return 0;
    
    if (c < lnd->firstInvalidCharacter)
        return [self mgs_rowOfValidCharacter:c];
    return [self mgs_cacheLineNumberDataUntilCharacter:c orLine:NSUIntegerMax];
}


- (NSUInteger)mgs_rowOfCharacter:(NSUInteger)c
{
    NSUInteger len = self.length;
    
    if (c > len)
        return NSNotFound;
    if (c == len)
        return [self mgs_lineCount] - 1;
    return [self mgs_rowOfMaybeInvalidCharacter:c];
}


- (NSUInteger)mgs_firstCharacterInRow:(NSUInteger)l
{
    MGSTextStorageLineNumberData *lnd = [self mgs_lineNumberData];
    NSMutableArray *fcla;
    NSUInteger c, maxl;
    
    fcla = lnd->firstCharacterOfEachLine;
    if ([fcla count] > l) {
        c = [[fcla objectAtIndex:l] unsignedIntegerValue];
        if (c < lnd->firstInvalidCharacter)
            return c;
    }
    
    maxl = [self mgs_cacheLineNumberDataUntilCharacter:NSUIntegerMax orLine:l];
    if (maxl < l)
        return NSNotFound;
    return [[fcla objectAtIndex:l] unsignedIntegerValue];
}


- (NSUInteger)mgs_characterAtIndex:(NSUInteger)i withinRow:(NSUInteger)l
{
    NSUInteger c, e;
    
    c = [self mgs_firstCharacterInRow:l];
    if (c == NSNotFound)
        return NSNotFound;
    if (c == [self length])
        return c;
    
    [self.mutableString getLineStart:NULL end:NULL contentsEnd:&e forRange:NSMakeRange(c, 0)];
    if (c+i < MAX(c, i)) /* Unsigned overflow */
        return e;
    return MIN(e, c+i);
}


@end
