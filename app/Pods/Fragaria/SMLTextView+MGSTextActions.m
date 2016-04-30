//
//  SMLTextView+MGSTextActions.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 09/02/15.
//
//

#import "SMLTextView.h"
#import "SMLTextViewPrivate.h"
#import "SMLTextView+MGSTextActions.h"
#import "MGSSyntaxDefinition.h"
#import "SMLSyntaxColouring.h"
#import "MGSExtraInterfaceController.h"
#import "MGSMutableSubstring.h"
#import "NSString+Fragaria.h"
#import "NSTextStorage+Fragaria.h"


@implementation SMLTextView (MGSTextActions)


/*
 
 - validateMenuItem:
 
 */
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    BOOL enableItem = YES;
    SEL action = [anItem action];
    
    // All items who should only be active if something is selected
    if (action == @selector(removeNeedlessWhitespace:) ||
        action == @selector(removeLineEndings:) ||
        action == @selector(entab:) ||
        action == @selector(detab:) ||
        action == @selector(capitalizeWord:) ||
        action == @selector(uppercaseCharacters:) ||
        action == @selector(lowercaseCharacters:)
        ) {
        if ([self selectedRange].length < 1) {
            enableItem = NO;
        }
    } else if (action == @selector(commentOrUncomment:) ) {
        // Comment Or Uncomment
        if ([self.syntaxColouring.syntaxDefinition.singleLineComments count] == 0) {
            enableItem = NO;
        }
    } else {
        enableItem = [super validateUserInterfaceItem:anItem];
    }
    
    return enableItem;
}


#pragma mark - Utilities


- (NSInteger)editSelectionArrayWithBlock:(void (^)(NSMutableString *string))b
{
    NSMutableString *string = [[self textStorage] mutableString];
    NSArray *newselection;
    NSInteger l0;
    
    l0 = [string length];
    
    newselection = [string enumerateMutableSubstringsFromRangeArray: [self selectedRanges]
    usingBlock:^(MGSMutableSubstring *substr, BOOL *stop) {
        NSMutableString *temp = [NSMutableString stringWithString:substr];
        b(temp);
        
        if ([self shouldChangeTextInRange:[substr superstringRange] replacementString:temp]) {
            [substr setString:temp];
            [self didChangeText];
        }
    }];
    [self setSelectedRanges:newselection];
    
    return [string length] - l0;
}


- (void)alignSelectionToLineBonduaries
{
    NSMutableIndexSet *indexset;
    NSArray *sel;
    NSMutableArray *newsel;
    NSValue *rangeval;
    NSRange range;
    NSMutableString *string = [[self textStorage] mutableString];
    
    indexset = [NSMutableIndexSet indexSet];
    newsel = [NSMutableArray array];
    
    sel = [self selectedRanges];
    for (rangeval in sel) {
        range = [string lineRangeForRange:[rangeval rangeValue]];
        if (range.length)
            [indexset addIndexesInRange:range];
        else /* Last line */
            [newsel addObject:[NSValue valueWithRange:range]];
    }
    
    [indexset enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [newsel addObject:[NSValue valueWithRange:range]];
    }];
    [self setSelectedRanges:newsel];
}


#pragma mark -
#pragma mark Text shifting


- (NSString *)makeIndentStringOfWidth:(NSInteger)width
{
    NSMutableString *res;
    NSInteger tabwidth, i;
    
    res = [NSMutableString string];
    tabwidth = self.tabWidth;
    
    if (!self.indentWithSpaces) {
        while (width >= tabwidth) {
            [res appendString:@"\t"];
            width -= tabwidth;
        }
    }
    for (i=0; i<width; i++)
        [res appendString:@" "];
    
    return [res copy];
}


- (void)shiftSelectionBy:(NSInteger)indent
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSInteger lchg;
    
    [self alignSelectionToLineBonduaries];
    lchg = [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string enumerateMutableSubstringsOfLinesUsingBlock:^(MGSMutableSubstring *line, BOOL *stop) {
            NSInteger width, newwidth;
            NSUInteger i;
            NSString *replStr;
            
            i = 0;
            while (i < [line length] && [whitespace characterIsMember:[line characterAtIndex:i]])
                i++;
            
            width = [line mgs_columnOfCharacter:i tabWidth:self.tabWidth];
            newwidth = MAX(0, width + indent);
            replStr = [self makeIndentStringOfWidth:newwidth];
            [line replaceCharactersInRange:NSMakeRange(0, i) withString:replStr];
        }];
    }];
    
    if (!lchg) NSBeep();
}


/*
 * - shiftLeft:
 */
- (IBAction)shiftLeft:(id)sender
{
    [self shiftSelectionBy:-self.indentWidth];
}


/*
 * - shiftRight:
 */
- (IBAction)shiftRight:(id)sender
{
    [self shiftSelectionBy:self.indentWidth];
}


#pragma mark -
#pragma mark Text manipulation


/*
 * - removeNeedlessWhitespace:
 */
- (IBAction)removeNeedlessWhitespace:(id)sender
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSInteger lchg;
    
    [self alignSelectionToLineBonduaries];
    lchg = [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string enumerateMutableSubstringsOfLinesUsingBlock:^(MGSMutableSubstring *line, BOOL *stop) {
            NSUInteger i, e;
            NSRange whitespaces;
            
            [line getLineStart:NULL end:NULL contentsEnd:&e forRange:NSMakeRange(0, line.length)];
            i = e;
        
            while (i > 0 && [whitespace characterIsMember:[line characterAtIndex:i-1]])
                i--;
            
            whitespaces = NSMakeRange(i, e - i);
            [line replaceCharactersInRange:whitespaces withString:@""];
        }];
    }];
    
    if (!lchg) NSBeep();
}


/*
 * - lowercaseCharacters:
 */
- (IBAction)lowercaseCharacters:(id)sender
{
    [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string setString:[string lowercaseString]];
    }];
}


/*
 * - uppercaseCharacters:
 */
- (IBAction)uppercaseCharacters:(id)sender
{
    [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string setString:[string uppercaseString]];
    }];
}


- (IBAction)capitalizeWord:(id)sender
{
    /* This is because NSResponder does not tag this action as an IBAction,
     * thus it does not appear in IB for linking. */
    [super capitalizeWord:sender];
}


/*
 * - entab:
 */
- (IBAction)entab:(id)sender
{
    [self.interfaceController displayEntabForTarget:self];
}


/*
 * - detabAction
 */
- (IBAction)detab:(id)sender
{
    [self.interfaceController displayDetabForTarget:self];
}


/*
 * - performEntabWithNumberOfSpaces:
 */
- (void)performEntabWithNumberOfSpaces:(NSInteger)numberOfSpaces
{
    [self alignSelectionToLineBonduaries];
    [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string enumerateMutableSubstringsOfLinesUsingBlock:^(MGSMutableSubstring *line, BOOL *stop) {
            NSRange thisSpace, prevSpaces, range;
            
            range = NSMakeRange(0, [line length]);
            prevSpaces = NSMakeRange(NSNotFound, 0);
            thisSpace = [line rangeOfString:@" " options:NSLiteralSearch range:range];
            while (thisSpace.length) {
                NSInteger phase;
                NSUInteger realLocation;
                
                if (NSMaxRange(prevSpaces) == thisSpace.location)
                    prevSpaces.length++;
                else
                    prevSpaces = thisSpace;
                
                realLocation = [line mgs_columnOfCharacter:NSMaxRange(prevSpaces) tabWidth:numberOfSpaces];
                phase = realLocation % numberOfSpaces;
                if (phase == 0) {
                    if (prevSpaces.length > 1) {
                        [line replaceCharactersInRange:prevSpaces withString:@"\t"];
                        thisSpace.location = prevSpaces.location;
                        thisSpace.length = 1;
                    }
                    prevSpaces = NSMakeRange(NSNotFound, 0);
                }
                
                range.location = NSMaxRange(thisSpace);
                range.length = [line length] - range.location;
                
                thisSpace = [line rangeOfString:@" " options:NSLiteralSearch range:range];
            }
        }];
    }];
}


/*
 * - performDetabWithNumberOfSpaces:
 */
- (void)performDetabWithNumberOfSpaces:(NSInteger)numberOfSpaces
{
    NSMutableString *spaces;
    NSInteger i;
    
    spaces = [NSMutableString string];
    for (i=0; i<numberOfSpaces; i++) {
        [spaces appendString:@" "];
    }
    
    [self alignSelectionToLineBonduaries];
    [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        [string enumerateMutableSubstringsOfLinesUsingBlock:^(MGSMutableSubstring *line, BOOL *stop) {
            NSRange tempRange, range;
            
            range = NSMakeRange(0, [line length]);
            tempRange = [line rangeOfString:@"\t" options:NSLiteralSearch range:range];
            while (tempRange.length) {
                NSInteger phase;
                NSString *replStr;
                
                if (numberOfSpaces) {
                    phase = [line mgs_columnOfCharacter:tempRange.location tabWidth:numberOfSpaces] % numberOfSpaces;
                    replStr = [spaces substringFromIndex:phase];
                } else {
                    replStr = @"";
                }
                [line replaceCharactersInRange:tempRange withString:replStr];
                
                range.location = tempRange.location + [replStr length];
                range.length = [line length] - range.location;
                
                tempRange = [line rangeOfString:@"\t" options:NSLiteralSearch range:range];
            }
        }];
    }];
}


- (IBAction)transpose:(id)sender
{
    /* This is because NSResponder does not tag this action as an IBAction,
     * thus it does not appear in IB for linking. */
    [super transpose:sender];
}


#pragma mark -
#pragma mark Goto

/*
 
 - goToLineAction:
 
 */
- (IBAction)goToLine:(id)sender
{
    [self.interfaceController displayGoToLineForTarget:self];
}


/*
 
 - performGoToLine:
 
 */
- (void)performGoToLine:(NSInteger)lineToGoTo setSelected:(BOOL)highlight
{
    NSUInteger idx, target;
    NSRange line;
    NSTextStorage *ts = self.textStorage;
    
    if (lineToGoTo < 1) {
        NSBeep();
        return;
    }
    target = lineToGoTo - 1;
    if (target >= ts.mgs_lineCount) {
        NSBeep();
        return;
    }
    
    idx = [ts mgs_firstCharacterInRow:target];
    line = [ts.string lineRangeForRange:NSMakeRange(idx, 0)];
    
    if (highlight)
        [self setSelectedRange:line];
    [self scrollRangeToVisible:line];
}


#pragma mark -
#pragma mark Tag manipulation


/*
 
 - closeTagAction:
 
 */
- (IBAction)closeTag:(id)sender
{
    NSRange selectedRange = [self selectedRange];
    if (selectedRange.length > 0) {
        NSBeep();
        return;
    }
    
    NSUInteger location = selectedRange.location;
    NSString *completeString = [self string];
    BOOL foundClosingBrace = NO;
    BOOL foundOpeningBrace = NO;
    
    while (location--) { // First check that there is a closing c i.e. >
        if ([completeString characterAtIndex:location] == '>') {
            foundClosingBrace = YES;
            break;
        }
    }
    
    if (!foundClosingBrace) {
        NSBeep();
        return;
    }
    
    NSInteger locationOfClosingBrace = location;
    NSInteger numberOfClosingTags = 0;
    
    while (location--) { // Then check for the opening brace i.e. <
        if ([completeString characterAtIndex:location] == '<') {
            // Divide into four checks as otherwise it will miss to skip the tag if it comes absolutely last in the document
            if (location + 4 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
                NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 4)];
                NSRange searchRange = NSMakeRange(0, [checkString length]);
                if ([checkString rangeOfString:@"<br>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<hr>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<!--" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<?" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<%" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                }
            }
            
            if (location + 5 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
                NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 5)];
                NSRange searchRange = NSMakeRange(0, [checkString length]);
                if ([checkString rangeOfString:@"<img " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<br/>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                }
            }
            
            if (location + 6 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
                NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 6)];
                NSRange searchRange = NSMakeRange(0, [checkString length]);
                if ([checkString rangeOfString:@"<br />" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<hr />" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<area " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<base " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<link " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<meta " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                }
            }
            
            if (location + 7 < [completeString length]) { // check that the tag is not one of the tags that aren't closed e.g. <br> and their variants
                NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 7)];
                NSRange searchRange = NSMakeRange(0, [checkString length]);
                if ([checkString rangeOfString:@"<frame " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<input " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                } else if ([checkString rangeOfString:@"<param " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
                    continue;
                }
            }
            
            NSScanner *selfClosingScanner = [NSScanner scannerWithString:[completeString substringWithRange:NSMakeRange(location, locationOfClosingBrace - location)]];
            [selfClosingScanner setCharactersToBeSkipped:nil];
            NSString *selfClosingScanString = [NSString string];
            [selfClosingScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@">"] intoString:&selfClosingScanString];
            
            if ([selfClosingScanString length] != 0) {
                if ([selfClosingScanString characterAtIndex:([selfClosingScanString length] - 1)] == '/') {
                    continue;
                }
            }
            
            if ([completeString characterAtIndex:location + 1] == '/') { // If it's a closing tag (e.g. </a>) continue the search
                numberOfClosingTags++;
                continue;
            } else {
                if (numberOfClosingTags) { // Try to find the "correct" tag to close by counting the number of closing tags and when they match up insert the created closing tag; if they don't write balanced code - well, tough luck...
                    numberOfClosingTags--;
                } else {
                    foundOpeningBrace = YES;
                    break;
                }
            }
        }
    }
    
    if (foundOpeningBrace == NO) {
        NSBeep();
        return;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:[completeString substringWithRange:NSMakeRange(location, locationOfClosingBrace - location)]];
    [scanner setCharactersToBeSkipped:nil];
    NSString *scanString = [NSString string];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" >/"] intoString:&scanString]; // Set the string to everything up to any of the characters (space),> or / so that it will catch things like <a href... as well as <br>
    
    NSMutableString *tagString = [NSMutableString stringWithString:scanString];
    NSInteger tagStringLength = [tagString length];
    if (tagStringLength == 0) {
        NSBeep();
        return;
    }
    
    [tagString insertString:@"/" atIndex:1];
    [tagString insertString:@">" atIndex:tagStringLength + 1];
    
    if ([self shouldChangeTextInRange:selectedRange replacementString:tagString]) { // Do it this way to mark it as an Undo
        [self replaceCharactersInRange:selectedRange withString:tagString];
        [self didChangeText];
    }
}


/*
 * - prepareForXML:
 */
- (IBAction)prepareForXML:(id)sender
{
    [self editSelectionArrayWithBlock:^(NSMutableString *stringToConvert) {
        NSRange allString = NSMakeRange(0, [stringToConvert length]);
        
        [stringToConvert replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:allString];
        [stringToConvert replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:allString];
        [stringToConvert replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:allString];
        [stringToConvert replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:allString];
    }];
}


#pragma mark -
#pragma mark Comment handling


/*
 * - commentOrUncomment:
 */
- (IBAction)commentOrUncomment:(id)sender
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString *comment = self.syntaxColouring.syntaxDefinition.singleLineComments[0];
    NSInteger lchg;
    
    [self alignSelectionToLineBonduaries];
    lchg = [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        NSRange commentRange = NSMakeRange(0, [comment length]);
        BOOL __block allCommented = YES;
        void (^workblock)(MGSMutableSubstring *, BOOL *);
        
        [string enumerateMutableSubstringsOfLinesUsingBlock:^(MGSMutableSubstring *line, BOOL *stop) {
            MGSMutableSubstring *tmp;
        
            tmp = [line mutableSubstringByLeftTrimmingCharactersFromSet:whitespace];
            if (![tmp hasPrefix:comment]) {
                allCommented = NO;
                *stop = YES;
            }
        }];
        
        if (allCommented) {
            workblock = ^void(MGSMutableSubstring *line, BOOL *stop) {
                MGSMutableSubstring *tmp;
                
                tmp = [line mutableSubstringByLeftTrimmingCharactersFromSet:whitespace];
                [tmp deleteCharactersInRange:commentRange];
            };
        } else {
            workblock = ^void(MGSMutableSubstring *line, BOOL *stop) {
                [line insertString:comment atIndex:0];
            };
        }
        [string enumerateMutableSubstringsOfLinesUsingBlock:workblock];
    }];
    
    if (!lchg) NSBeep();
}


#pragma mark -
#pragma mark Line endings


/*
 * - removeLineEndings:
 */
- (IBAction)removeLineEndings:(id)sender
{
    [self editSelectionArrayWithBlock:^(NSMutableString *string) {
        NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
        NSRange range;
        
        range = [string rangeOfCharacterFromSet:newlines];
        while (range.length) {
            [string replaceCharactersInRange:range withString:@""];
            range.length = [string length] - range.location;
            range = [string rangeOfCharacterFromSet:newlines options:0 range:range];
        }
    }];
}


@end
