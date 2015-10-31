//
//  MGSLineNumberView.m
//  MGSFragaria
//
//  Copyright (c) 2015 Daniele Cattaneo
//

//
//  NoodleLineNumberView.m
//  NoodleKit
//
//  Created by Paul Kim on 9/28/08.
//  Copyright (c) 2008 Noodlesoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import <tgmath.h>
#import "MGSFragariaView.h"
#import "MGSLineNumberView.h"
#import "MGSBreakpointDelegate.h"


#define RULER_MARGIN		5.0


@implementation MGSLineNumberView {
    // Array of character indices for the beginning of each line
    NSMutableArray      *_lineIndices;
    // When text is edited, this is the start of the editing region. All line
    // calculations after this point are invalid and need to be recalculated.
    NSUInteger          _invalidCharacterIndex;
    
    NSUInteger _mouseDownLineTracking;
    NSRect     _mouseDownRectTracking;
    
    NSMutableDictionary *_markerImages;
    NSSize _markerImagesSize;
    
    NSDictionary *_breakpointData;
}


/* Properties implemented by superclass */
@dynamic clientView;


- (id)initWithScrollView:(NSScrollView *)aScrollView
{
    return [self initWithScrollView:aScrollView fragaria:nil];
}


- (id)initWithScrollView:(NSScrollView *)aScrollView fragaria:(MGSFragariaView *)fragaria
{
    if ((self = [super initWithScrollView:aScrollView orientation:NSVerticalRuler]) != nil)
    {
        _lineIndices = [[NSMutableArray alloc] init];
        _startingLineNumber = 1;
        _markerImagesSize = NSMakeSize(0,0);
        _markerImages = [[NSMutableDictionary alloc] init];
        _fragaria = fragaria;
        
        _showsLineNumbers = YES;
        _backgroundColor = [NSColor colorWithCalibratedWhite:0.94 alpha:1.0];
        _minimumWidth = 40;
        _font = [NSFont fontWithName:@"Menlo" size:11];
        _textColor = [NSColor colorWithCalibratedWhite:0.42 alpha:1.0];
        _breakpointData = [[NSDictionary alloc] init];
        
        [self setClientView:[aScrollView documentView]];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Property getters & setters


- (void)setDecorations:(NSDictionary *)decorations
{
    _decorations = decorations;
    [self setRuleThickness:[self requiredThickness]];
    [self setNeedsDisplay:YES];
}


- (void)setMinimumWidth:(CGFloat)minimumWidth
{
    _minimumWidth = minimumWidth;
    [self setRuleThickness:[self requiredThickness]];
    [self setNeedsDisplay:YES];
}


- (void)setStartingLineNumber:(NSUInteger)startingLineNumber
{
    _startingLineNumber = startingLineNumber;
    [self setNeedsDisplay:YES];
}


- (void)setShowsLineNumbers:(BOOL)drawsLineNumbers
{
    _showsLineNumbers = drawsLineNumbers;
    [self setRuleThickness:[self requiredThickness]];
    [self setNeedsDisplay:YES];
}


- (void)setFont:(NSFont *)font
{
    _font = font;
    [self setRuleThickness:[self requiredThickness]];
    [self setNeedsDisplay:YES];
}


- (void)setTextColor:(NSColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay:YES];
}


- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}


- (void)layoutManagerWillChangeTextStorage
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:NSTextStorageDidProcessEditingNotification
      object:self.clientView.textStorage];
}


- (void)layoutManagerDidChangeTextStorage
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(textStorageDidProcessEditing:)
      name:NSTextStorageDidProcessEditingNotification object:self.clientView.textStorage];
    [self invalidateLineIndicesFromCharacterIndex:0];
}


- (void)setClientView:(SMLTextView *)aView
{
	SMLTextView *oldClientView;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
	oldClientView = [self clientView];
	
    if (oldClientView && (oldClientView != aView))
    {
        [self layoutManagerWillChangeTextStorage];
        [nc removeObserver:self name:NSViewFrameDidChangeNotification object:oldClientView];
    }
    [super setClientView:aView];
    if (aView)
    {
        [nc addObserver:self selector:@selector(textViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:aView];
        [self layoutManagerDidChangeTextStorage];
    }
}


- (void)setBreakpointDelegate:(id<MGSBreakpointDelegate>)breakpointDelegate
{
    _breakpointDelegate = breakpointDelegate;
    [self reloadBreakpointData];
}


#pragma mark - Line number cache


- (NSMutableArray *)lineIndices
{
	if (_invalidCharacterIndex < NSUIntegerMax)
	{
		[self calculateLines];
	}
	return _lineIndices;
}


// Forces recalculation of line indices starting from the given index
- (void)invalidateLineIndicesFromCharacterIndex:(NSUInteger)charIndex
{
    _invalidCharacterIndex = MIN(charIndex, _invalidCharacterIndex);
}


- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    NSTextStorage       *storage;
    NSRange             range;
    
    storage = [notification object];

    // Invalidate the line indices. They will be recalculated and re-cached on demand.
    range = [storage editedRange];
    if (range.location != NSNotFound)
    {
        [self invalidateLineIndicesFromCharacterIndex:range.location];
        [self setNeedsDisplay:YES];
    }
}


- (void)calculateLines
{
    id              view;

    view = [self clientView];
    
    NSUInteger      charIndex, stringLength, lineEnd, contentEnd, count, lineIndex;
    NSString        *text;
    
    text = [view string];
    stringLength = [text length];
    count = [_lineIndices count];

    charIndex = 0;
    lineIndex = [self lineNumberForCharacterIndex:_invalidCharacterIndex inText:text];
    if (count > 0)
    {
        charIndex = [[_lineIndices objectAtIndex:lineIndex] unsignedIntegerValue];
    }
    
    do
    {
        if (lineIndex < count)
        {
            [_lineIndices replaceObjectAtIndex:lineIndex withObject:[NSNumber numberWithUnsignedInteger:charIndex]];
        }
        else
        {
            [_lineIndices addObject:[NSNumber numberWithUnsignedInteger:charIndex]];
        }
        
        charIndex = NSMaxRange([text lineRangeForRange:NSMakeRange(charIndex, 0)]);
        lineIndex++;
    }
    while (charIndex < stringLength);
    
    if (lineIndex < count)
    {
        [_lineIndices removeObjectsInRange:NSMakeRange(lineIndex, count - lineIndex)];
    }
    _invalidCharacterIndex = NSUIntegerMax;

    // Check if text ends with a new line.
    [text getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineIndices lastObject] unsignedIntegerValue], 0)];
    if (contentEnd < lineEnd)
    {
        [_lineIndices addObject:[NSNumber numberWithUnsignedInteger:charIndex]];
    }
}


- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)charIndex inText:(NSString *)text
{
    NSUInteger			left, right, mid, lineStart;
	NSMutableArray		*lines;

    if (_invalidCharacterIndex < NSUIntegerMax)
    {
        // We do not want to risk calculating the indices again since we are
        // probably doing it right now, thus possibly causing an infinite loop.
        lines = _lineIndices;
    }
    else
    {
        lines = [self lineIndices];
    }
	
    // Binary search
    left = 0;
    right = [lines count];

    while ((right - left) > 1)
    {
        mid = (right + left) / 2;
        lineStart = [[lines objectAtIndex:mid] unsignedIntegerValue];
        
        if (charIndex < lineStart)
        {
            right = mid;
        }
        else if (charIndex > lineStart)
        {
            left = mid;
        }
        else
        {
            return mid;
        }
    }
    return left;
}


#pragma mark - Automatic thickness control

+ (NSSet *)keyPathsForValuesAffectingRequiredThickness
{
    return [NSSet setWithArray:@[
                                 @"decorations",
                                 @"minimumWidth",
                                 @"drawsLineNumbers",
                                 @"font",
                                 @"startingLineNumber",
                                 ]];
}

- (CGFloat)requiredThickness
{
    NSUInteger			lineCount, digits, i;
    NSMutableString     *sampleString;
    NSSize              stringSize;
    CGFloat decorationsWidth;
    
    if (_showsLineNumbers) {
        lineCount = [[self lineIndices] count] + (_startingLineNumber - 1);
        digits = 1;
        if (lineCount > 0)
            digits = (NSUInteger)log10(lineCount) + 1;
        
        sampleString = [NSMutableString string];
        for (i = 0; i < digits; i++) {
            // Use "8" since it is one of the fatter numbers. Anything but "1"
            // will probably be ok here. I could be pedantic and actually find the fattest
            // number for the current font but nah.
            [sampleString appendString:@"8"];
        }
        stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
        stringSize.width += RULER_MARGIN;
    } else {
        stringSize = NSZeroSize;
    }
    
    decorationsWidth = [self decorationColumnWidth];

	// Round up the value. There is a bug on 10.4 where the display gets all
    // wonky when scrolling if you don't return an integral value here.
    return ceil(MAX(_minimumWidth, decorationsWidth + stringSize.width + RULER_MARGIN));
}


- (CGFloat)decorationColumnWidth
{
    NSArray *linesWithDecorations = [_decorations allKeys];
    NSNumber *line;
    NSUInteger linenum;
    CGFloat value, max = 0;
    NSRect decorationRect;

    for (line in linesWithDecorations) {
        linenum = [line integerValue] - 1;
        if (linenum < [self.lineIndices count]) {
            decorationRect = [self decorationRectOfLine:linenum];
            value = decorationRect.origin.x + decorationRect.size.width;
            if (value > max) max = value;
        }
    }
    return max;
}


- (void)viewWillDraw
{
    CGFloat         oldThickness, newThickness;
    
    [super viewWillDraw];
    
    if (_invalidCharacterIndex < NSUIntegerMax)
        [self calculateLines];
    
    // See if we need to adjust the width of the view
    oldThickness = [self ruleThickness];
    newThickness = [self requiredThickness];
    if (fabs(oldThickness - newThickness) > 1) {
        [self willChangeValueForKey:@"requiredThickness"];
        [self setRuleThickness:newThickness];
        [self didChangeValueForKey:@"requiredThickness"];
    }
}


#pragma mark - Drawing utilities


- (NSDictionary*)textAttributes
{
    return @{ NSFontAttributeName: self.font,
              NSForegroundColorAttributeName: self.textColor };
}


- (NSDictionary*)highlightTextAttributesForLine:(NSUInteger)line
{
    NSColor *markerColor = [_breakpointData objectForKey:@(line + 1)];
    NSColor *textCol = [self.textColor highlightWithLevel:[markerColor alphaComponent]];
    return @{ NSFontAttributeName: self.font,
              NSForegroundColorAttributeName: textCol };
}


#pragma mark - Main draw methods


- (void)textViewFrameDidChange:(NSNotification *)notification
{
    /* Delay the call because otherwise, when drawRect is called, the text
     * view's layout manager will still be set to the old frame (and will
     * return inconsistent values). */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay:YES];
    });
}


- (void)drawRect:(NSRect)dirtyRect
{
    SMLTextView	*view;
	NSRect bounds;
    NSRect visibleRect;
    NSLayoutManager	*layoutManager;
    NSRange range, glyphRange;
    NSString *labelText;
    NSUInteger index, line;
    NSRect wholeLineRect;
    CGFloat ypos;
    NSDictionary *currentTextAttributes;
    NSMutableArray *lines;
    NSAttributedString *drawingAttributedString;
    CGContextRef drawingContext;
    NSColor *markerColor;

	bounds = [self bounds];
    view = [self clientView];
    visibleRect = [[[self scrollView] contentView] bounds];

	[self.backgroundColor set];
    NSRectFill(bounds);
    
    [[NSColor lightGrayColor] set];
    NSBezierPath *dottedLine = [NSBezierPath bezierPath];
    [dottedLine moveToPoint:NSMakePoint(bounds.size.width-0.5, 0)];
    [dottedLine lineToPoint:NSMakePoint(bounds.size.width-0.5, bounds.size.height)];
    CGFloat dash[2];
    dash[0] = 1.0f;
    dash[1] = 2.0f;
    [dottedLine setLineDash:dash count:2 phase:visibleRect.origin.y];
    [dottedLine stroke];

    layoutManager = [view layoutManager];

    drawingContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGAffineTransform flipTransform = {1, 0, 0, -1, 0, 0};
    CGContextSetTextMatrix(drawingContext, flipTransform);
    
    lines = [self lineIndices];

    // Find the characters that are currently visible, make a range,  then fudge the range a tad in case
    // there is an extra new line at end. It doesn't show up in the glyphs so would not be accounted for.
    glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[view textContainer]];
    range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    range.length++;

    for (line = [self lineNumberForCharacterIndex:range.location inText:[view string]]; line < [lines count]; line++)
    {
        index = [[lines objectAtIndex:line] unsignedIntegerValue];
        
        if (NSLocationInRange(index, range))
        {
            wholeLineRect = [self wholeLineRectForLine:line];

            // Note that the ruler view is only as tall as the visible
            // portion. Need to compensate for the clipview's coordinates.
            ypos = wholeLineRect.origin.y;

            if ((markerColor = [_breakpointData objectForKey:@(line + 1)])) {
                [self drawMarkerInRect:wholeLineRect withColor:markerColor];
                currentTextAttributes = [self highlightTextAttributesForLine:line];
            } else {
                currentTextAttributes = [self textAttributes];
            }

            if (self.showsLineNumbers)
            {
                // Draw line numbers first so that error images won't be buried underneath long line numbers.
                // Line numbers are internally stored starting at 0
                labelText = [NSString stringWithFormat:@"%jd", (intmax_t)line + _startingLineNumber];
                drawingAttributedString = [[NSAttributedString alloc] initWithString:labelText attributes:currentTextAttributes];

                CGFloat descent, leading;
                CTLineRef textline;
                textline = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)drawingAttributedString);
                CGFloat width = CTLineGetTypographicBounds(textline, NULL, &descent, &leading);
                
                CGFloat xpos = NSWidth(bounds) - width - RULER_MARGIN;
                CGFloat baselinepos = ypos + NSHeight(wholeLineRect) - floor(descent + 0.5) - floor(leading+0.5);
                CGContextSetTextPosition(drawingContext, xpos, baselinepos);
                CTLineDraw(textline, drawingContext);
                CFRelease(textline);
            }

            [self drawDecorationOfLine:line];
        }
        if (index > NSMaxRange(range))
        {
            break;
        }
    }
}


/// @param line uses zero-based indexing.
- (NSRect)wholeLineRectForLine:(NSUInteger)line
{
    id			      view;
    NSRect            visibleRect;
    NSLayoutManager	  *layoutManager;
    NSTextContainer	  *container;
    NSUInteger        index, stringLength;
    NSRect            rect;
    NSMutableArray    *lines;
    NSRect            wholeLineRect = NSZeroRect;

    view = [self clientView];
    layoutManager = [view layoutManager];
    container = [view textContainer];

    visibleRect = [[[self scrollView] contentView] bounds];
    stringLength = [[view string] length];

    lines = [self lineIndices];

    index = [[lines objectAtIndex:line] unsignedIntegerValue];

    NSUInteger glyphIdx = [layoutManager glyphIndexForCharacterAtIndex:index];
    if (index < stringLength)
        rect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIdx effectiveRange:NULL];
    else
        rect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIdx, 0) inTextContainer:container];

    // Note that the ruler view is only as tall as the visible
    // portion. Need to compensate for the clipview's coordinates.
    CGFloat ypos = [view textContainerInset].height + NSMinY(rect) - NSMinY(visibleRect);

    wholeLineRect.size.width = self.bounds.size.width;
    wholeLineRect.size.height = rect.size.height;
    wholeLineRect.origin.x = 0;
    wholeLineRect.origin.y = ypos;

    return wholeLineRect;
}


/// @returns zero-based indexing.
- (NSUInteger)lineNumberForLocation:(CGFloat)location
{
	NSUInteger		line, count, index, rectCount, i;
	NSRectArray		rects;
	NSRect			visibleRect;
	NSLayoutManager	*layoutManager;
	NSTextContainer	*container;
	NSRange			nullRange;
	NSMutableArray	*lines;
	id				view;
    
	view = [self clientView];
	visibleRect = [[[self scrollView] contentView] bounds];
	
	lines = [self lineIndices];
    
	location += NSMinY(visibleRect);
	
    nullRange = NSMakeRange(NSNotFound, 0);
    layoutManager = [view layoutManager];
    container = [view textContainer];
    count = [lines count];
    
    for (line = 0; line < count; line++)
    {
        index = [[lines objectAtIndex:line] unsignedIntegerValue];
        
        rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(index, 0)
                             withinSelectedCharacterRange:nullRange
                                          inTextContainer:container
                                                rectCount:&rectCount];
        
        for (i = 0; i < rectCount; i++)
        {
            if (location < NSMinY(rects[i]) && line)
                return line-1;
            else if (location < NSMaxY(rects[i]))
                return line;
        }
    }
	return NSNotFound;
}


/// @param line uses zero-based indexing.
- (void)drawMarkerInRect:(NSRect)rect withColor:(NSColor *)markerColor
{
    NSRect centeredRect, alignedRect;
    CGFloat height;
    
    height = rect.size.height;
    centeredRect = rect;
    centeredRect.origin.y += (rect.size.height - height) / 2.0;
    centeredRect.origin.x += RULER_MARGIN;
    centeredRect.size.height = height;
    centeredRect.size.width -= RULER_MARGIN;
    
    alignedRect = [self backingAlignedRect:centeredRect options:NSAlignAllEdgesOutward];

    NSImage *defaultImage = [self defaultMarkerImageWithSize:centeredRect.size color:markerColor];
    [defaultImage drawInRect:alignedRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:YES hints:nil];
}


/// @param line uses zero-based indexing.
- (void)drawDecorationOfLine:(NSUInteger)line
{
    NSImage *image;
    NSRect centeredRect;
    
    image = [_decorations objectForKey:@(line + 1)];
    if (!image) return;
    
    centeredRect = [self decorationRectOfLine:line];

    [image drawInRect:centeredRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:YES hints:nil];
}


- (NSRect)decorationRectOfLine:(NSUInteger)line
{
    NSRect rect;
    NSImage *image;
    CGFloat height;
    NSRect centeredRect;
    CGFloat margin, fontsize;
    
    image = [_decorations objectForKey:@(line+1)];
    if (!image) return NSZeroRect;
    
    rect = [self wholeLineRectForLine:line];
    fontsize = self.font.pointSize;
    
    margin = MAX(1.0, MIN(fontsize / 11.0, rect.size.height / 12.0));
    height = MIN(fontsize, rect.size.height - 2.0 * margin);
    
    centeredRect = rect;
    centeredRect.origin.y += rect.size.height - height - 1.0;
    centeredRect.origin.x += RULER_MARGIN + margin;
    centeredRect.size.height = height;
    centeredRect.size.width = image.size.width / (image.size.height / height);
    
    return [self backingAlignedRect:centeredRect options:NSAlignAllEdgesOutward];
}


/* Adapted from Noodlekit (github.com/MrNoodle/NoodleKit) by Paul Kim. */
- (NSImage *)defaultMarkerImageWithSize:(NSSize)size color:(NSColor*)colorBase  {
    NSImage *markerImage;
    
    if (NSEqualSizes(size, _markerImagesSize)) {
        markerImage = _markerImages[[colorBase description]];
        if (markerImage) {
            return markerImage;
        }
    } else {
        [_markerImages removeAllObjects];
    }
    
    markerImage = [NSImage.alloc initWithSize:size];
    NSCustomImageRep *rep = [NSCustomImageRep.alloc initWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        BOOL yosemite = floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
        NSRect rect;
        NSBezierPath *path;
        CGFloat lineWidth = (dstRect.size.height < 12.0 ? 1 : (dstRect.size.height / 12.0));
        CGFloat cornerRadius = yosemite ? 0 : 3.0;
        
        if (yosemite) {
            rect.origin = NSZeroPoint;
            rect.size = dstRect.size;
            rect.size.height--;
            rect.origin.y++;
        } else {
            rect.origin = NSMakePoint(lineWidth/2.0, lineWidth/2.0);
            rect.size = NSMakeSize(dstRect.size.width-lineWidth, dstRect.size.height-lineWidth);
        }
        
        NSPoint tip = NSMakePoint(NSMaxX(rect), NSMinY(rect) + NSHeight(rect)/2);
        CGFloat arrowEndX = NSMaxX(rect)-NSHeight(rect)/2.6;
        
        path = [NSBezierPath bezierPath];
        [path moveToPoint:tip];
        [path lineToPoint:NSMakePoint(arrowEndX, NSMaxY(rect))];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + cornerRadius, NSMaxY(rect) - cornerRadius) radius:cornerRadius startAngle:90 endAngle:180];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + cornerRadius, NSMinY(rect) + cornerRadius) radius:cornerRadius startAngle:180 endAngle:270];
        [path lineToPoint:NSMakePoint(arrowEndX, NSMinY(rect))];
        [path closePath];
        
        if (yosemite) {
            [colorBase setFill];
            [path fill];
        } else {
            NSColor *colorFill1, *colorFill2, *colorStroke, *tmp;
            CGFloat a;
            
            tmp = [colorBase colorUsingColorSpaceName:NSDeviceRGBColorSpace];
            a = tmp.alphaComponent;
            
            colorFill1 = [[colorBase highlightWithLevel:0.6] colorWithAlphaComponent:a];
            colorFill2 = [[colorBase highlightWithLevel:0.1] colorWithAlphaComponent:a];
            
            NSGradient *fill = [[NSGradient alloc] initWithColors:@[colorFill1, colorFill2]];
            [fill drawInBezierPath:path angle:-90.0];
            
            colorStroke = [[colorBase shadowWithLevel:0.3] colorWithAlphaComponent:a];
            [colorStroke set];
            [path setLineWidth:lineWidth];
            [path stroke];
        }
        
        return YES;
    }];
    
    [rep setSize:size];
    [markerImage addRepresentation:rep];
    [markerImage setName:[colorBase description]];
    [_markerImages setValue:markerImage forKey:[colorBase description]];
    _markerImagesSize = size;
    return markerImage;
}


#pragma mark - NSResponder


- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger line = [self lineNumberForLocation:location.y];
    NSRect imageRect;
    BOOL errorHit = NO;

    if (line != NSNotFound) {
        _mouseDownLineTracking = line + 1; // now has 1-based index.
        _mouseDownRectTracking = NSMakeRect(0.0, 0.0, 0.0, 0.0);

        if ([_decorations objectForKey:@(_mouseDownLineTracking)]) {
            _mouseDownRectTracking = imageRect = [self decorationRectOfLine:line];

            if (CGRectContainsPoint(imageRect, location))
                errorHit = YES;
        }

        if (errorHit) {
            _mouseDownRectTracking = imageRect;
        } else {
            [self breakpointClickedOnLine:_mouseDownLineTracking];
        }
    }
}


- (void)mouseUp:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger line = [self lineNumberForLocation:location.y]; // method returns 0-based index.

    if (line != _mouseDownLineTracking - 1 || location.x > self.frame.size.width) {
        [self breakpointClickedOnLine:_mouseDownLineTracking];
    } else {
        if ([_decorations objectForKey:@(_mouseDownLineTracking)]) {
            if (CGRectContainsPoint(_mouseDownRectTracking, location)) {
                _selectedLineNumber = line;
                [NSApp sendAction:_decorationActionSelector to:_decorationActionTarget from:self];
            }
        }
    }
}


#pragma mark - Delegate handling


- (void)reloadBreakpointData
{
    NSMutableDictionary *data;
    NSSet *linesWithBreakpoints;
    NSNumber *line;
    
    if (!_breakpointDelegate) {
        _breakpointData = [[NSDictionary alloc] init];
        return;
    }
        
    if ([_breakpointDelegate respondsToSelector:@selector(colouredBreakpointsForFragaria:)]) {
        _breakpointData = [_breakpointDelegate colouredBreakpointsForFragaria:self.fragaria];
        return;
    }
    
    data = [NSMutableDictionary dictionary];
    
    if ([_breakpointDelegate respondsToSelector:@selector(breakpointsForFragaria:)]) {
        linesWithBreakpoints = [_breakpointDelegate breakpointsForFragaria:self.fragaria];
    } else {
        [NSException raise:@"MGSBrokenBreakpointDelegate" format:@"The breakpoint "
         "delegate %@ of %@ does not implement at least one of the following "
         "methods: -colouredBreakpointsForFragaria:, -breakpointsForFragaria:.",
         _breakpointDelegate, self];
    }
    
    NSColor *defaultMarkerColor = [NSColor colorWithCalibratedRed:1.0 green:0.5 blue:1.0 alpha:1.0];
    
    if ([_breakpointDelegate respondsToSelector:@selector(breakpointColourForLine:ofFragaria:)]) {
        for (line in linesWithBreakpoints) {
            NSColor *markerColor = [_breakpointDelegate breakpointColourForLine:[line integerValue] ofFragaria:self.fragaria];
            if (markerColor)
                [data setObject:markerColor forKey:line];
            else
                [data setObject:defaultMarkerColor forKey:line];
        }
    } else {
        for (line in linesWithBreakpoints) {
            [data setObject:defaultMarkerColor forKey:line];
        }
    }

    _breakpointData = [data copy];
    [self setNeedsDisplay:YES];
}


- (void)breakpointClickedOnLine:(NSUInteger)line
{
    _selectedLineNumber = line;
    
    if ([_breakpointDelegate respondsToSelector:@selector(toggleBreakpointForFragaria:onLine:)]) {
        [_breakpointDelegate toggleBreakpointForFragaria:self.fragaria onLine:line];
    }

    [self reloadBreakpointData];
}


@end
