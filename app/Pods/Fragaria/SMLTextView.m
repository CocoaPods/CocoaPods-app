/*
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria

 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net

 Copyright 2004-2009 Peter Borg

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 this file except in compliance with the License. You may obtain a copy of the
 License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for the
 specific language governing permissions and limitations under the License.
 */

#import "SMLTextView.h"
#import "SMLTextViewPrivate.h"
#import "SMLTextView+MGSTextActions.h"
#import "SMLLayoutManager.h"
#import "MGSSyntaxDefinition.h"
#import "SMLSyntaxColouring.h"
#import "MGSExtraInterfaceController.h"
#import "NSString+Fragaria.h"
#import "NSTextStorage+Fragaria.h"


static BOOL CharacterIsBrace(unichar c)
{
    NSCharacterSet *braces = [NSCharacterSet characterSetWithCharactersInString:@"()[]{}<>"];
    return [braces characterIsMember:c];
}


static BOOL CharacterIsClosingBrace(unichar c)
{
    NSCharacterSet *braces = [NSCharacterSet characterSetWithCharactersInString:@")]}>"];
    return [braces characterIsMember:c];
}


static unichar OpeningBraceForClosingBrace(unichar c)
{
    switch (c) {
        case ')': return '(';
        case ']': return '[';
        case '}': return '{';
        case '>': return '<';
    }
    return 0;
}


static unichar ClosingBraceForOpeningBrace(unichar c)
{
    switch (c) {
        case '(': return ')';
        case '[': return ']';
        case '{': return '}';
        case '<': return '>';
    }
    return 0;
}


#pragma mark - Implementation


@implementation SMLTextView {
    BOOL isDragging;
    NSPoint startPoint;
    NSPoint startOrigin;

    CGFloat pageGuideX;
    NSColor *pageGuideColor;

    NSRect currentLineRect;

    NSTimer *autocompleteWordsTimer;
    NSArray *cachedKeywords;
    id __weak syntaxDefOfCachedKeywords;
}


/* Properties implemented by superclass */
@dynamic delegate, layoutManager;

@synthesize lineWrap = _lineWrap;
@synthesize showsPageGuide = _showsPageGuide;


#pragma mark - Properties - Internal

/*
 * @property fragaria
 * (synthesized)
 */

/*
 * @property inspectedCharacterIndexes
 * (synthesized)
 */


#pragma mark - Properties - Appearance and Behaviours

/*
 * @property currentLineHighlightColour
 * (synthesized)
 */
- (void)setCurrentLineHighlightColour:(NSColor *)currentLineHighlightColour
{
    _currentLineHighlightColour = currentLineHighlightColour;
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * @property highlightCurrentLine
 */
- (void)setHighlightsCurrentLine:(BOOL)highlightCurrentLine
{
    [self setNeedsDisplayInRect:currentLineRect];
    _highlightsCurrentLine = highlightCurrentLine;
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * @property insertionPointColor
 */
- (void)setInsertionPointColor:(NSColor *)insertionPointColor
{
    [super setInsertionPointColor:insertionPointColor];
    [self configurePageGuide];

}

- (NSColor *)insertionPointColor
{
    return [super insertionPointColor];
}


/*
 * @property lineWrap
 *   see /developer/examples/appkit/TextSizingExample
 */
- (void)setLineWrap:(BOOL)value
{
    _lineWrap = value;
    [self updateLineWrap];
	[self.syntaxColouring invalidateAllColouring];
}


/*
 * @property lineWrapsAtPageGuide
 */
- (void)setLineWrapsAtPageGuide:(BOOL)lineWrapsAtPageGuide
{
    _lineWrapsAtPageGuide = lineWrapsAtPageGuide;
    [self updateLineWrap];
    [self.syntaxColouring invalidateAllColouring];
}


/*
 * @property pageGuideColumn
 */
- (void)setPageGuideColumn:(NSInteger)pageGuideColumn
{
    _pageGuideColumn = pageGuideColumn;
    [self configurePageGuide];
    [self updateLineWrap];
    [self.syntaxColouring invalidateAllColouring];
}


/*
 * @property showsInvisibleCharacters
 */
- (void)setShowsInvisibleCharacters:(BOOL)showsInvisibleCharacters
{
	self.layoutManager.showsInvisibleCharacters = showsInvisibleCharacters;
}

- (BOOL)showsInvisibleCharacters
{
	return self.layoutManager.showsInvisibleCharacters;
}


/*
 * @property showsPageGuide
 */
- (void)setShowsPageGuide:(BOOL)showsPageGuide
{
    _showsPageGuide = showsPageGuide;
    [self configurePageGuide];
}

- (BOOL)showsPageGuide
{
    return _showsPageGuide;
}


/*
 * @property tabWidth
 */
- (void)setTabWidth:(NSInteger)tabWidth
{
    _tabWidth = tabWidth;

    // Set the width of every tab by first checking the size of the tab in spaces in the current font,
    // and then remove all tabs that sets automatically and then set the default tab stop distance.
    NSMutableString *sizeString = [NSMutableString string];
    NSInteger numberOfSpaces = _tabWidth;
    while (numberOfSpaces--) {
        [sizeString appendString:@" "];
    }
    NSDictionary *ta = [self typingAttributes];
    CGFloat sizeOfTab = [sizeString sizeWithAttributes:ta].width;

    NSMutableParagraphStyle *style = [[ta objectForKey:NSParagraphStyleAttributeName] mutableCopy];
    if (!style) style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    NSArray *array = [style tabStops];
    for (id item in array) {
        [style removeTabStop:item];
    }
    [style setDefaultTabInterval:sizeOfTab];
    
    NSMutableDictionary *attributes = [ta mutableCopy];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    [self setTypingAttributes:attributes];
    
    [[self textStorage] addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,[[self textStorage] length])];
}


/*
 * @property lineSpacing
 */
- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple
{
    NSMutableDictionary *ta;
    NSMutableParagraphStyle *ps;
    NSRange wholeRange = NSMakeRange(0, self.string.length);
    
    ta = [self.typingAttributes mutableCopy];
    ps = [[ta objectForKey:NSParagraphStyleAttributeName] mutableCopy];
    if (!ps) ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [ps setLineHeightMultiple:lineHeightMultiple];
    
    [self.textStorage addAttribute:NSParagraphStyleAttributeName value:ps range:wholeRange];
    
    [ta setObject:ps forKey:NSParagraphStyleAttributeName];
    [self setTypingAttributes:ta];
}

- (CGFloat)lineHeightMultiple
{
    NSParagraphStyle *ps;
    
    ps = [self.typingAttributes objectForKey:NSParagraphStyleAttributeName];
    return ps.lineHeightMultiple;
}


/*
 * @property textColor
 */
- (void)setTextColor:(NSColor *)textColor
{
    /* setFont: also updates our typing attributes */
    [super setTextColor:textColor];
    [self configurePageGuide];
}

- (NSColor *)textColor
{
    NSColor *res;
    
    res = [[self typingAttributes] objectForKey:NSForegroundColorAttributeName];
    return res ? res : [NSColor blackColor];
}


/*
 * @property textFont
 */
- (void)setTextFont:(NSFont *)textFont
{
    /* setFont: also updates our typing attributes */
    [self setFont:textFont];
    [self.layoutManager setInvisibleCharactersFont:textFont];
    [self configurePageGuide];
    [self setTabWidth:_tabWidth];
}

- (NSFont *)textFont
{
    return [[self typingAttributes] objectForKey:NSFontAttributeName];
}


/*
 * @property textInvisibleCharactersColour
 */
- (void)setTextInvisibleCharactersColour:(NSColor *)textInvisibleCharactersColour
{
	self.layoutManager.invisibleCharactersColour = textInvisibleCharactersColour;

}

- (NSColor *)textInvisibleCharactersColour
{
	return self.layoutManager.invisibleCharactersColour;
}

/*
 * -(void)setLayoutOrientation:
 */
- (void)setLayoutOrientation:(NSTextLayoutOrientation)theOrientation
{
    /* Currently, vertical layout breaks the ruler */
    [super setLayoutOrientation:NSTextLayoutOrientationHorizontal];
}


/*
 * - setSyntaxColoured:
 */
- (void)setSyntaxColoured:(BOOL)syntaxColoured
{
    if (_syntaxColoured != syntaxColoured)
        [self.syntaxColouring invalidateAllColouring];
    _syntaxColoured = syntaxColoured;
}


/*
 * - setRichText:
 */
- (void)setRichText:(BOOL)richText
{
    [super setRichText:NO];
}


#pragma mark - Strings - Properties and Methods


/*
 * - attributedStringWithTemporaryAttributesApplied
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	// recolour the entire textview content
	NSRange wholeRange;
	
	wholeRange = NSMakeRange(0, self.string.length);
	[self.syntaxColouring recolourRange:wholeRange];
	
	// get content with layout manager temporary attributes persisted
	return [self.layoutManager attributedStringWithTemporaryAttributesApplied];
}


#pragma mark - Getting Line and Column Information


- (void)getRow:(NSUInteger * __nullable)r column:(NSUInteger * __nullable)c forCharacterIndex:(NSUInteger)i
{
    NSTextStorage *ts = self.textStorage;
    NSString *temp;
    NSRange lr;
    NSUInteger j;
    
    if (r)
        *r = [ts mgs_rowOfCharacter:i];
    if (c) {
        lr = [ts.string mgs_lineRangeForCharacterIndex:i];
        if (lr.location != NSNotFound) {
            temp = [ts.string substringWithRange:lr];
            j = i - lr.location;
            *c = [temp mgs_columnOfCharacter:j tabWidth:self.tabWidth];
        } else
            *c = NSNotFound;
    }
}


- (void)getRow:(NSUInteger * __nullable)r indexInRow:(NSUInteger * __nullable)c forCharacterIndex:(NSUInteger)i
{
    NSTextStorage *ts = self.textStorage;
    NSUInteger fc;
    NSRange lr;
    
    if (r) {
        *r = [ts mgs_rowOfCharacter:i];
        if (c) {
            if (*r != NSNotFound) {
                fc = [ts mgs_firstCharacterInRow:*r];
                *c = i - fc;
            } else
                *c = NSNotFound;
        }
    } else if (c) {
        lr = [ts.string mgs_lineRangeForCharacterIndex:i];
        if (lr.location != NSNotFound)
            *c = i - lr.location;
        else
            *c = NSNotFound;
    }
}


- (NSUInteger)characterIndexAtColumn:(NSUInteger)c withinRow:(NSUInteger)r
{
    NSUInteger fcr, ci;
    NSRange lr;
    NSString *tmp, *s;
    
    fcr = [self.textStorage mgs_firstCharacterInRow:r];
    if (fcr == NSNotFound)
        return NSNotFound;
    
    s = self.string;
    lr = [s lineRangeForRange:NSMakeRange(fcr, 0)];
    tmp = [s substringWithRange:lr];
    ci = [tmp mgs_characterInColumn:c tabWidth:self.tabWidth];
    if (ci == NSNotFound)
        return NSNotFound;
    return fcr + ci;
}


- (NSUInteger)characterIndexAtIndex:(NSUInteger)c withinRow:(NSUInteger)r
{
    return [self.textStorage mgs_characterAtIndex:c withinRow:r];
}


#pragma mark - Instance methods - Initializers and Setup


/*
 * - initWithFrame:
 */
- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        SMLLayoutManager *layoutManager = [[SMLLayoutManager alloc] init];
        [[self textContainer] replaceLayoutManager:layoutManager];
        
        _interfaceController = [[MGSExtraInterfaceController alloc] init];
        
        _syntaxColouring = [[SMLSyntaxColouring alloc] initWithLayoutManager:layoutManager];
        _syntaxColoured = YES;
        
        [self setDefaults];
        
        isDragging = NO;
    }
    return self;
}


/*
 * - setDefaults
 */
- (void)setDefaults
{
    [self setVerticallyResizable:YES];
    [self setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self setAutoresizingMask:NSViewWidthSizable];
    [self setAllowsUndo:YES];

    [self setUsesFindBar:YES];
    [self setIncrementalSearchingEnabled:NO];

    [self setAllowsDocumentBackgroundColorChange:NO];
    [self setRichText:NO];
    [self setImportsGraphics:NO];
    [self setUsesFontPanel:NO];

    [self setAutomaticDashSubstitutionEnabled:NO];
    [self setAutomaticQuoteSubstitutionEnabled:NO];
    [self setAutomaticDataDetectionEnabled:YES];
    [self setAutomaticTextReplacementEnabled:YES];
    [self setAutomaticLinkDetectionEnabled:YES];
    [self setContinuousSpellCheckingEnabled:NO];
    [self setGrammarCheckingEnabled:NO];

    _lineWrap = YES;
    [self updateLineWrap];
    
    self.currentLineHighlightColour = [NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.71 alpha:1.0];
    self.indentWidth = 4;
    self.tabWidth = 4;
    self.pageGuideColumn = 80;
    self.autoCompleteDelay = 1.0;
    self.textFont = [NSFont fontWithName:@"Menlo" size:11];
    self.indentNewLinesAutomatically = YES;
    self.showsMatchingBraces = YES;
    self.useTabStops = YES;
    self.indentBracesAutomatically = YES;
    
    [self configurePageGuide];
}


#pragma mark - Menu Item Validation


/*
 * - validateMenuItem
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(toggleAutomaticDashSubstitution:))
        return NO;
    if ([menuItem action] == @selector(toggleAutomaticQuoteSubstitution:))
        return NO;
    if ([menuItem action] == @selector(changeLayoutOrientation:))
        return NO;
    return [super validateMenuItem:menuItem];
}


#pragma mark - Copy and paste

/*
 * - paste
 */
-(void)paste:(id)sender
{
    // let super paste
    [super paste:sender];

    // add the NSTextView  to the info dict
    NSDictionary *info = @{@"NSTextView": self};

    // send paste notification
    NSNotification *note = [NSNotification notificationWithName:@"MGSTextDidPasteNotification" object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:note];

    // inform delegate of Fragaria paste
    if ([self.delegate respondsToSelector:@selector(mgsTextDidPaste:)]) {
        [(id)self.delegate mgsTextDidPaste:note];
    }
}


#pragma mark - Drawing

/*
 * - isOpaque
 */
- (BOOL)isOpaque
{
    return YES;
}


/*
 * - drawRect:
 */
- (void)drawRect:(NSRect)rect
{
    const NSRect *dirtyRects;
    NSRange recolourRange;
    NSInteger rectCount, i;
    
    [self getRectsBeingDrawn:&dirtyRects count:&rectCount];
    
    if (self.isSyntaxColoured) {
        for (i=0; i<rectCount; i++) {
            recolourRange = [[self layoutManager] glyphRangeForBoundingRect:dirtyRects[i] inTextContainer:[self textContainer]];
            recolourRange = [[self layoutManager] characterRangeForGlyphRange:recolourRange actualGlyphRange:NULL];
            [self.syntaxColouring recolourRange:recolourRange];
        }
    }
    
    [super drawRect:rect];
    
    if (self.showsPageGuide == YES) {
        NSRect bounds = [self bounds];
        if ([self needsToDrawRect:NSMakeRect(pageGuideX, 0, 1, bounds.size.height)] == YES) { // So that it doesn't draw the line if only e.g. the cursor updates
            [pageGuideColor set];
            [NSBezierPath strokeRect:NSMakeRect(pageGuideX, 0, 0, bounds.size.height)];
        }
    }
}


#pragma mark - Line Highlighting


/*
 * - drawViewBackgroundInRect:
 */
- (void)drawViewBackgroundInRect:(NSRect)rect
{
    [super drawViewBackgroundInRect:rect];
    
    if ([self needsToDrawRect:currentLineRect]) {
        [self.currentLineHighlightColour set];
        [NSBezierPath fillRect:currentLineRect];
    }
}


/*
 * - viewWillDraw
 */
- (void)viewWillDraw
{
    NSRect lineRect;
    
    lineRect = [self lineHighlightingRect];
    if (!NSEqualRects(lineRect, currentLineRect)) {
        [self setNeedsDisplayInRect:currentLineRect];
        currentLineRect = lineRect;
        [self setNeedsDisplayInRect:currentLineRect];
    }
}


/*
 * - lineHighlightingRect
 */
- (NSRect)lineHighlightingRect
{
    NSMutableString *ms;
    NSRange selRange, lineRange, multipleLineRange;
    NSUInteger sm, em, s, e;
    NSRect lineRect;
    NSLayoutManager *lm = [self layoutManager];

    if (!_highlightsCurrentLine) return NSZeroRect;

    selRange = [self selectedRange];
    ms = [[self textStorage] mutableString];
    
    [ms getLineStart:&sm end:NULL contentsEnd:&em forRange:selRange];
    multipleLineRange = NSMakeRange(sm, em - sm);
    [ms getLineStart:&s end:NULL contentsEnd:&e forRange:NSMakeRange(selRange.location, 0)];
    lineRange = NSMakeRange(s, e - s);
    
    if (NSEqualRanges(lineRange, multipleLineRange)) {
        lineRange = [lm glyphRangeForCharacterRange:lineRange actualCharacterRange:NULL];
        lineRect = [lm boundingRectForGlyphRange:lineRange inTextContainer:[self textContainer]];
        lineRect.origin.x = 0;
        lineRect.size.width = [self bounds].size.width;
        return lineRect;
    }
    return NSZeroRect;
}


/*
 * - setSelectedRanges:
 */
- (void)setSelectedRanges:(NSArray *)selectedRanges
{
    [self setNeedsDisplayInRect:currentLineRect];
    [super setSelectedRanges:selectedRanges];
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * - setSelectedRange:
 */
- (void)setSelectedRange:(NSRange)selectedRange
{
    [self setNeedsDisplayInRect:currentLineRect];
    [super setSelectedRange:selectedRange];
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * - setSelectedRange:affinity:stillSelecting:
 */
- (void)setSelectedRange:(NSRange)charRange affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)stillSelectingFlag
{
    [self setNeedsDisplayInRect:currentLineRect];
    [super setSelectedRange:charRange affinity:affinity stillSelecting:stillSelectingFlag];
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * - setSelectedRanges:affinity:stillSelecting:
 */
- (void)setSelectedRanges:(NSArray *)ranges affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)stillSelectingFlag
{
    [self setNeedsDisplayInRect:currentLineRect];
    [super setSelectedRanges:ranges affinity:affinity stillSelecting:stillSelectingFlag];
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


/*
 * - setFrame:
 */
- (void)setFrame:(NSRect)bounds
{
    [self setNeedsDisplayInRect:currentLineRect];
    [super setFrame:bounds];
    currentLineRect = [self lineHighlightingRect];
    [self setNeedsDisplayInRect:currentLineRect];
}


#pragma mark - Mouse event handling


/*
 * - flagsChanged:
 */
- (void)flagsChanged:(NSEvent *)theEvent
{
    [super flagsChanged:theEvent];

    if (([theEvent modifierFlags] & NSAlternateKeyMask) && ([theEvent modifierFlags] & NSCommandKeyMask)) {
        isDragging = YES;
        [[NSCursor openHandCursor] set];
    } else {
        isDragging = NO;
        [[NSCursor IBeamCursor] set];
    }
}


/*
 * - mouseDown:
 */
- (void)mouseDown:(NSEvent *)theEvent
{
    if (([theEvent modifierFlags] & NSAlternateKeyMask) && ([theEvent modifierFlags] & NSCommandKeyMask)) { // If the option and command keys are pressed, change the cursor to grab-cursor
        startPoint = [theEvent locationInWindow];
        startOrigin = [[[self enclosingScrollView] contentView] documentVisibleRect].origin;
        isDragging = YES;
    } else {
        [super mouseDown:theEvent];
    }
}


/*
 * - mouseDragged:
 */
- (void)mouseDragged:(NSEvent *)theEvent
{
    if (isDragging) {
        [self scrollPoint:NSMakePoint(startOrigin.x - ([theEvent locationInWindow].x - startPoint.x) * 3, startOrigin.y + ([theEvent locationInWindow].y - startPoint.y) * 3)];
    } else {
        [super mouseDragged:theEvent];
    }
}


/*
 * - mouseMoved:
 */
- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    if (isDragging)
        [[NSCursor openHandCursor] set];
}


#pragma mark - Contextual Menu


/*
 * - menuForEvent:
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    NSMenu *menu = [super menuForEvent:theEvent];
    NSMenu *extraMenu = [self.interfaceController contextMenu];
    NSMenuItem *item, *newItem;
    
    /* We want to add our new menu items after cut-copy-paste, but before
     * the standard NSTextView useless stuff (spelling checker, character
     * substitution, ...). These items are separated from cut-copy-paste by
     * a separator, and this usually is the last separator in the menu.
     * So we find this separator and we add our new items after it. */
    
    /* Find the last separator in the menu */
    NSInteger i = [menu numberOfItems] - 1;
    for (; i>=0; i--) {
        NSMenuItem *tmp = [menu itemAtIndex:i];
        if ([tmp isSeparatorItem])
            break;
    }
    
    /* If no separators found, append to the end of the menu. Otherwise,
     * add the new items after this last separator. */
    i = i < 0 ? [menu numberOfItems] : i + 1;
    
    for (item in [extraMenu itemArray]) {
        newItem = [item copy];
        [menu insertItem:newItem atIndex:i++];
    }
    
    /* We add another separator after our new stuff, if it's not at the end
     * of the menu. */
    if (i < [menu numberOfItems])
        [menu insertItem:[NSMenuItem separatorItem] atIndex:i];

    return menu;
}


#pragma mark - Tab and page guide handling

/*
 * - insertTab:
 */
- (void)insertTab:(id)sender
{
    BOOL shouldShiftText = NO;

    if ([self selectedRange].length > 0) { // Check to see if the selection is in the text or if it's at the beginning of a line or in whitespace; if one doesn't do this one shifts the line if there's only one suggestion in the auto-complete
        NSRange rangeOfFirstLine = [[self string] lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
        NSUInteger firstCharacterOfFirstLine = rangeOfFirstLine.location;
        while ([[self string] characterAtIndex:firstCharacterOfFirstLine] == ' ' || [[self string] characterAtIndex:firstCharacterOfFirstLine] == '\t') {
            firstCharacterOfFirstLine++;
        }
        if ([self selectedRange].location <= firstCharacterOfFirstLine) {
            shouldShiftText = YES;
        }
    }

    if (shouldShiftText) {
        [self shiftRight:nil];
    } else if (self.indentWithSpaces) {
        NSMutableString *spacesString = [NSMutableString string];
        NSInteger numberOfSpacesPerTab = self.tabWidth;
        if (self.useTabStops) {
            NSInteger locationOnLine = [self realColumnOfCharacter:self.selectedRange.location];
            if (numberOfSpacesPerTab != 0) {
                NSInteger numberOfSpacesLess = locationOnLine % numberOfSpacesPerTab;
                numberOfSpacesPerTab = numberOfSpacesPerTab - numberOfSpacesLess;
            }
        }
        while (numberOfSpacesPerTab--) {
            [spacesString appendString:@" "];
        }

        [self insertText:spacesString];
    } else if ([self selectedRange].length > 0) { // If there's only one word matching in auto-complete there's no list but just the rest of the word inserted and selected; and if you do a normal tab then the text is removed so this will put the cursor at the end of that word
        [self setSelectedRange:NSMakeRange(NSMaxRange([self selectedRange]), 0)];
    } else {
        [super insertTab:sender];
    }
}


/*
 * - realColumnOfCharacter:
 */
- (NSUInteger)realColumnOfCharacter:(NSUInteger)c
{
    NSString *str, *line;
    NSRange lineRange;
    
    str = [self string];
    lineRange = [str lineRangeForRange:NSMakeRange(c, 0)];
    line = [str substringWithRange:lineRange];
    return [line mgs_columnOfCharacter:c - lineRange.location tabWidth:self.tabWidth];
}


#pragma mark - Text handling


/*
 * - insertText:
 */
- (void)insertText:(NSString *)input
{
    NSString *aString;

    if ([input isKindOfClass:[NSAttributedString class]])
        aString = [(NSAttributedString *)input string];
    else
        aString = input;

    if ([aString isEqualToString:@"}"] && self.indentNewLinesAutomatically && self.indentBracesAutomatically) {
        [self shiftBackToLastOpenBrace];
    }

    [super insertText:input];

    if ([aString isEqualToString:@"("] && self.insertClosingParenthesisAutomatically) {
        [self insertStringAfterInsertionPoint:@")"];
    } else if ([aString isEqualToString:@"{"] && self.insertClosingBraceAutomatically) {
        [self insertStringAfterInsertionPoint:@"}"];
    }

    if ([aString length] == 1 && self.showsMatchingBraces) {
        if (CharacterIsClosingBrace([aString characterAtIndex:0])) {
            [self showBraceMatchingBrace:[aString characterAtIndex:0]];
        }
    }

    if (self.autoCompleteEnabled)
        [self scheduleAutocomplete];
}


/*
 * - insertStringAfterInsertionPoint
 */
- (void)insertStringAfterInsertionPoint:(NSString*)string
{
    NSRange selectedRange = [self selectedRange];
    if ([self shouldChangeTextInRange:selectedRange replacementString:string]) {
        [self replaceCharactersInRange:selectedRange withString:string];
        [self didChangeText];
        [self setSelectedRange:NSMakeRange(selectedRange.location, 0)];
    }
}


/*
 * - findBeginningOfNestedBlock:openedByCharacter:closedByCharacter:
 */
- (NSInteger)findBeginningOfNestedBlock:(NSInteger)charIdx openedByCharacter:(unichar)open closedByCharacter:(unichar)close
{
    NSInteger skipMatchingBrace = 0;
    NSString *completeString = [self string];
    unichar characterToCheck;

    while (charIdx--) {
        characterToCheck = [completeString characterAtIndex:charIdx];
        if (characterToCheck == open) {
            if (!skipMatchingBrace) {
                return charIdx;
            } else {
                skipMatchingBrace--;
            }
        } else if (characterToCheck == close) {
            skipMatchingBrace++;
        }
    }
    return NSNotFound;
}


/*
 * - findEndOfNestedBlock:openedByCharacter:closedByCharacter:
 */
- (NSInteger)findEndOfNestedBlock:(NSInteger)charIdx openedByCharacter:(unichar)open closedByCharacter:(unichar)close
{
    NSInteger skipMatchingBrace = 0;
    NSString *completeString = [self string];
    NSInteger lengthOfString = [completeString length];
    unichar characterToCheck;

    while (++charIdx < lengthOfString) {
        characterToCheck = [completeString characterAtIndex:charIdx];
        if (characterToCheck == close) {
            if (!skipMatchingBrace) {
                return charIdx;
            } else {
                skipMatchingBrace--;
            }
        } else if (characterToCheck == open) {
            skipMatchingBrace++;
        }
    }
    return NSNotFound;
}


/*
 * - showBraceMatchingBrace:
 */
- (void)showBraceMatchingBrace:(unichar)characterToCheck;
{
    NSInteger cursorLocation;
    unichar matchingBrace;

    matchingBrace = OpeningBraceForClosingBrace(characterToCheck);

    cursorLocation = [self selectedRange].location - 1;
    if (cursorLocation < 0) return;

    cursorLocation = [self findBeginningOfNestedBlock:cursorLocation
                                    openedByCharacter:matchingBrace closedByCharacter:characterToCheck];
    if (cursorLocation != NSNotFound)
        [self showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
    else
        NSBeep();
}


/*
 * - shiftBackToLastOpenBrace
 */
- (void)shiftBackToLastOpenBrace
{
    NSString *completeString = [self string];
    NSInteger lineLocation = [self selectedRange].location;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    NSRange currentLineRange = [completeString lineRangeForRange:NSMakeRange(lineLocation, 0)];
    NSInteger lineStart = currentLineRange.location;

    // If there are any characters before } on the line, don't indent
    NSInteger i = lineLocation;
    while (--i >= lineStart) {
        if (![whitespaceCharacterSet characterIsMember:[completeString characterAtIndex:i]])
            return;
    }

    // Find the matching closing brace
    NSInteger location;
    location = [self findBeginningOfNestedBlock:lineLocation openedByCharacter:'{' closedByCharacter:'}'];
    if (location == NSNotFound) return;

    // If we have found the opening brace check first how much
    // space is in front of that line so the same amount can be
    // inserted in front of the new line.
    // If we found that space, replace the indenting of our line with the indenting from the opening brace line.
    // Otherwise just remove all the whitespace before the closing brace.
    NSString *openingBraceLineWhitespaceString;
    NSRange openingBraceLineRange = [completeString lineRangeForRange:NSMakeRange(location, 0)];
    NSString *openingBraceLine = [completeString substringWithRange:openingBraceLineRange];
    NSScanner *openingLineScanner = [[NSScanner alloc] initWithString:openingBraceLine];
    [openingLineScanner setCharactersToBeSkipped:nil];

    BOOL found = [openingLineScanner scanCharactersFromSet:whitespaceCharacterSet intoString:&openingBraceLineWhitespaceString];
    if (!found) {
        openingBraceLineWhitespaceString = @"";
    }

    // Replace the beginning of the line with the new indenting
    NSRange startInsertLineRange;
    startInsertLineRange = NSMakeRange(currentLineRange.location, lineLocation - currentLineRange.location);
    if ([self shouldChangeTextInRange:startInsertLineRange replacementString:openingBraceLineWhitespaceString]) {
        [self replaceCharactersInRange:startInsertLineRange withString:openingBraceLineWhitespaceString];
        [self didChangeText];
        [self setSelectedRange:NSMakeRange(currentLineRange.location + [openingBraceLineWhitespaceString length], 0)];
    }
}


/*
 * - insertNewline:
 */
- (void)insertNewline:(id)sender
{
    [super insertNewline:sender];

    // If we should indent automatically, check the previous line and scan all the whitespace at the beginning of the line into a string and insert that string into the new line
    NSString *lastLineString = [[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]];
    if (self.indentNewLinesAutomatically) {
        NSString *previousLineWhitespaceString;
        NSScanner *previousLineScanner = [[NSScanner alloc] initWithString:[[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]]];
        [previousLineScanner setCharactersToBeSkipped:nil];
        if ([previousLineScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&previousLineWhitespaceString]) {
            [self insertText:previousLineWhitespaceString];
        }

        if (self.indentBracesAutomatically) {
            NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSInteger idx = [lastLineString length];
            while (idx--) {
                if ([characterSet characterIsMember:[lastLineString characterAtIndex:idx]]) {
                    continue;
                }
                if ([lastLineString characterAtIndex:idx] == '{') {
                    [self insertTab:nil];
                }
                break;
            }
        }
    }
}


#pragma mark - Selection handling

/*
 * - selectionRangeForProposedRange:granularity:
 *
 *  If the user double-clicks an opening/closing brace, select the whole block
 *  enclosed by the corresponding brace pair.
 */
- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity
{
    // If it's not a mouse event return unchanged
    NSEventType eventType = [[NSApp currentEvent] type];
    if (eventType != NSLeftMouseDown && eventType != NSLeftMouseUp) {
        return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
    }

    if (granularity != NSSelectByWord || [[self string] length] == proposedSelRange.location || [[NSApp currentEvent] clickCount] != 2) { // If it's not a double-click return unchanged
        return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
    }

    NSUInteger location = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByCharacter].location;
    NSInteger originalLocation = location;

    NSString *completeString = [self string];
    unichar characterToCheck = [completeString characterAtIndex:location];
    NSUInteger lengthOfString = [completeString length];
    if (lengthOfString == proposedSelRange.location) { // To avoid crash if a double-click occurs after any text
        return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
    }


    BOOL triedToMatchBrace = NO;
    unichar matchingBrace;

    if (CharacterIsBrace(characterToCheck)) {
        triedToMatchBrace = YES;
        if (CharacterIsClosingBrace(characterToCheck)) {
            matchingBrace = OpeningBraceForClosingBrace(characterToCheck);
            location = [self findBeginningOfNestedBlock:location openedByCharacter:matchingBrace closedByCharacter:characterToCheck];
            if (location != NSNotFound)
                return NSMakeRange(location, originalLocation - location + 1);
            NSBeep();
        } else {
            matchingBrace = ClosingBraceForOpeningBrace(characterToCheck);
            location = [self findEndOfNestedBlock:location openedByCharacter:characterToCheck closedByCharacter:matchingBrace];
            if (location != NSNotFound)
                return NSMakeRange(originalLocation, location - originalLocation + 1);
            NSBeep();
        }
    }

    // If it has a found a "starting" brace but not found a match, a double-click should only select the "starting" brace and not what it usually would select at a double-click
    if (triedToMatchBrace) {
        return [super selectionRangeForProposedRange:NSMakeRange(proposedSelRange.location, 1) granularity:NSSelectByCharacter];
    } else {
        
        /* Hack for Objective-C, C and C++. If a dot or a colon is found inside
         * the range that Cocoa would select, the range is trimmed to the left
         * and/or to the right to exclude the things that are before and after
         * the dot/colon. */
        
        NSInteger startLocation = originalLocation;
        NSInteger stopLocation = originalLocation;
        NSInteger minLocation = [super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord].location;
        NSInteger maxLocation = NSMaxRange([super selectionRangeForProposedRange:proposedSelRange granularity:NSSelectByWord]);

        BOOL hasFoundSomething = NO;
        while (--startLocation >= minLocation) {
            if ([completeString characterAtIndex:startLocation] == '.' || [completeString characterAtIndex:startLocation] == ':') {
                hasFoundSomething = YES;
                break;
            }
        }

        while (++stopLocation < maxLocation) {
            if ([completeString characterAtIndex:stopLocation] == '.' || [completeString characterAtIndex:stopLocation] == ':') {
                hasFoundSomething = YES;
                break;
            }
        }

        if (hasFoundSomething == YES) {
            return NSMakeRange(startLocation + 1, stopLocation - startLocation - 1);
        } else {
            return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
        }
    }
}


#pragma mark - Auto Completion


/*
 * - scheduleAutocomplete
 */
- (void)scheduleAutocomplete
{
    if (!autocompleteWordsTimer) {
        autocompleteWordsTimer = [NSTimer
          scheduledTimerWithTimeInterval:self.autoCompleteDelay
          target:self selector:@selector(autocompleteWordsTimerSelector:)
          userInfo:nil repeats:NO];
    }
    [autocompleteWordsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.autoCompleteDelay]];
}


/*
 * - autocompleteWordsTimerSelector:
 */
- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer
{
    NSRange selectedRange = [self selectedRange];
    NSString *completeString = [self string];
    NSUInteger stringLength = [completeString length];

    if (selectedRange.location <= stringLength && selectedRange.length == 0 && stringLength != 0) {
        if (selectedRange.location == stringLength) { // If we're at the very end of the document
            [self complete:nil];
        } else {
            unichar characterAfterSelection = [completeString characterAtIndex:selectedRange.location];
            if ([[NSCharacterSet symbolCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:characterAfterSelection] || selectedRange.location == stringLength) { // Don't autocomplete if we're in the middle of a word
                [self complete:nil];
            }
        }
    }
}


/*
 * - complete:
 */
- (void)complete:(id)sender
{
    /* If somebody triggers autocompletion with ESC, we don't want to trigger
     * it again in the future because of the timer */
    if (autocompleteWordsTimer) {
        [autocompleteWordsTimer invalidate];
        autocompleteWordsTimer = nil;
    }
    [super complete:sender];
}


/*
 * - rangeForUserCompletion
 */
- (NSRange)rangeForUserCompletion
{
    NSRange cursor = [self selectedRange];
    NSUInteger loc = cursor.location;

    // Check for selections (can only autocomplete when nothing is selected)
    if (cursor.length > 0)
    {
        return NSMakeRange(NSNotFound, 0);
    }

    // Cannot autocomplete on first character
    if (loc == 0)
    {
        return NSMakeRange(NSNotFound, 0);
    }

    // Create char set with characters valid for variables
    NSCharacterSet* variableChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789_\\"];

    NSString* text = [self string];

    // Can only autocomplete on variable names
    if (![variableChars characterIsMember:[text characterAtIndex:loc-1]])
    {
        return NSMakeRange(NSNotFound, 0);
    }

    // TODO: Check if we are in a string

    // Search backwards in string until we hit a non-variable char
    NSUInteger numChars = 1;
    NSUInteger searchLoc = loc - 1;
    while (searchLoc > 0)
    {
        if ([variableChars characterIsMember:[text characterAtIndex:searchLoc-1]])
        {
            numChars += 1;
            searchLoc -= 1;
        }
        else
        {
            break;
        }
    }

    return NSMakeRange(loc-numChars, numChars);
}


/*
 * - completionsForPartialWordRange:indexOfSelectedItem;
 */
- (NSArray*)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    id <SMLAutoCompleteDelegate> delegate;
    
    if (!self.autoCompleteDelegate)
        delegate = self.syntaxColouring.syntaxDefinition;
    else
        delegate = self.autoCompleteDelegate;
    if (!delegate) return @[];
    
    NSMutableArray* matchArray = [NSMutableArray array];

    // get all completions
    NSMutableArray* allCompletions = [[delegate completions] mutableCopy];
    
    if (!allCompletions)
        allCompletions = [NSMutableArray array];
    
    /* Add the keywords, if the option to add keywords is on. */
    if (self.autoCompleteWithKeywords) {
        if (syntaxDefOfCachedKeywords != self.syntaxColouring.syntaxDefinition || !cachedKeywords) {
            NSArray *tmp = [self.syntaxColouring.syntaxDefinition.keywords allObjects];
            cachedKeywords = [tmp sortedArrayUsingSelector:@selector(compare:)];
            syntaxDefOfCachedKeywords = self.syntaxColouring.syntaxDefinition;
        }
        [allCompletions addObjectsFromArray:cachedKeywords];
    }

    // get string to match
    NSString *matchString = [[self string] substringWithRange:charRange];

    // build array of suitable suggestions
    for (NSString* completeWord in allCompletions)
    {
        if ([completeWord rangeOfString:matchString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [completeWord length])].location == 0)
        {
            [matchArray addObject:completeWord];
        }
    }

    return matchArray;
}


#pragma mark - Line Wrap

/*
 * - updateLineWrap
 *   see http://developer.apple.com/library/mac/#samplecode/TextSizingExample
 *   The readme file in the above example has very good info on how to configure NSTextView instances.
 */
- (void)updateLineWrap {
    NSSize contentSize;

    // get control properties
    NSScrollView *textScrollView = [self enclosingScrollView];
    NSTextContainer *textContainer = [self textContainer];

    if (textScrollView) {
        // content view is clipview
        contentSize = [textScrollView contentSize];
    } else {
        /* scroll view may not be already there */
        contentSize = [self frame].size;
    }

    if (self.lineWrap) {

        if (self.lineWrapsAtPageGuide) {

            float initialWidth = textScrollView.frame.size.width;

            // set modified contentsize
            contentSize.width = pageGuideX+.5+textContainer.lineFragmentPadding;
            
            // setup text container
            [textContainer setWidthTracksTextView:NO];
            [textContainer setHeightTracksTextView:NO];
            [textContainer setContainerSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];

            // setup text view
            [self setFrameSize:contentSize];
            [self setHorizontallyResizable: YES];
            [self setVerticallyResizable: YES];
            [self setMinSize:contentSize];
            [self setMaxSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];

            // setup scroll view
            [textScrollView setHasHorizontalScroller:pageGuideX > initialWidth];
        } else {

            // setup text view
            [self setFrameSize:contentSize];
            [self setHorizontallyResizable: NO];
            [self setVerticallyResizable: YES];
            [self setMinSize:NSMakeSize(10, contentSize.height)];
            [self setMaxSize:NSMakeSize(10, CGFLOAT_MAX)];

            // setup text container
            [textContainer setWidthTracksTextView:YES];
            [textContainer setHeightTracksTextView:NO];
            [textContainer setContainerSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];

            // setup scroll view
            [textScrollView setHasHorizontalScroller:NO];
        }
    } else {

        // setup text container
        [textContainer setWidthTracksTextView:NO];
        [textContainer setHeightTracksTextView:NO];
        [textContainer setContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];

        // setup text view
        [self setFrameSize:contentSize];
        [self setHorizontallyResizable: YES];
        [self setVerticallyResizable: YES];
        [self setMinSize:contentSize];
        [self setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];

        // setup scroll view
        [textScrollView setHasHorizontalScroller:YES];
    }

    // invalidate the glyph layout
    [[self layoutManager] textContainerChangedGeometry:textContainer];

    // redraw the display and reposition scrollers
    [textScrollView reflectScrolledClipView:textScrollView.contentView];
    [textScrollView setNeedsDisplay:YES];
}


/*
 * - viewDidEndLiveResize
 */
- (void)viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    BOOL needsScroller = self.lineWrapsAtPageGuide && pageGuideX > self.enclosingScrollView.frame.size.width;
    self.enclosingScrollView.hasHorizontalScroller = needsScroller;
}

#pragma mark - Page Guide


/*
 * - configurePageGuide
 */
- (void)configurePageGuide
{
    NSDictionary *sizeAttribute = [self typingAttributes];

    NSString *sizeString = @" ";
    CGFloat sizeOfCharacter = [sizeString sizeWithAttributes:sizeAttribute].width;
    pageGuideX = floor(sizeOfCharacter * (self.pageGuideColumn + 1)) - 1.5f; // -1.5 to put it between the two characters and draw only on one pixel and not two (as the system draws it in a special way), and that's also why the width above is set to zero

    NSColor *color = self.textColor;
    pageGuideColor = [color colorWithAlphaComponent:([color alphaComponent] / 4)]; // Use the same colour as the text but with more transparency

    [self display]; // To reflect the new values in the view
}


@end
