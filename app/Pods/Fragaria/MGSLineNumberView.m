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
#import "NSTextStorage+Fragaria.h"
#import "NSSet+Fragaria.h"


#define RULER_MARGIN		5.0


typedef enum {
    MGSGutterHitTypeOutside = -1,
    MGSGutterHitTypeBreakpoint,
    MGSGutterHitTypeDecoration
} MGSGutterHitType;


@implementation MGSLineNumberView
{
    NSUInteger _mouseDownLineTracking;
    NSRect _mouseDownRectTracking;
    MGSGutterHitType _lastHitPosition;
    
    CGFloat _maxDigitWidthOfCurrentFont;
    NSMutableDictionary *_markerImages;
    NSSize _markerImagesSize;
    
    NSDictionary *_breakpointData;
    NSUInteger _lastLineCount;
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
        _startingLineNumber = 1;
        _markerImagesSize = NSMakeSize(0,0);
        _markerImages = [[NSMutableDictionary alloc] init];
        _fragaria = fragaria;
        
        _showsLineNumbers = YES;
        _backgroundColor = [NSColor colorWithCalibratedWhite:0.94 alpha:1.0];
        _minimumWidth = 40;
        
        _font = [NSFont fontWithName:@"Menlo" size:11];
        _textColor = [NSColor colorWithCalibratedWhite:0.42 alpha:1.0];
        [self updateDigitWidthCache];
        
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
    [self updateDigitWidthCache];
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
    _lastLineCount = self.clientView.textStorage.mgs_lineCount;
    [nc addObserver:self selector:@selector(textStorageDidProcessEditing:)
      name:NSTextStorageDidProcessEditingNotification object:self.clientView.textStorage];
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


- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    id <MGSBreakpointDelegate> bd;
    NSTextStorage *ts;
    NSRange ecr, elr;
    NSInteger charDelta, lineDelta;
    
    bd = self.breakpointDelegate;
    if ([bd respondsToSelector:
         @selector(fixBreakpointsOfAddedLines:inLineRange:ofFragaria:)]) {
        ts = self.clientView.textStorage;
        charDelta = ts.changeInLength;
        if (charDelta && self.lineCount != _lastLineCount) {
            lineDelta = self.lineCount - _lastLineCount;
            
            ecr = ts.editedRange;
            elr.location = [ts mgs_rowOfCharacter:ecr.location];
            if (ecr.length)
                elr.length = [ts mgs_rowOfCharacter:NSMaxRange(ecr)] - elr.location;
            else
                elr.length = 0;
            elr.location++;
            elr.length++;
            
            [bd fixBreakpointsOfAddedLines:lineDelta inLineRange:elr ofFragaria:_fragaria];
        }
    }
    _lastLineCount = self.lineCount;
    
    [self setNeedsDisplay:YES];
}


#pragma mark - Automatic thickness control


- (NSUInteger)lineCount
{
    return self.clientView.textStorage.mgs_lineCount;
}


+ (NSSet *)keyPathsForValuesAffectingRequiredThickness
{
    return [NSSet setWithArray:@[@"decorations", @"minimumWidth",
      @"drawsLineNumbers", @"font", @"startingLineNumber"]];
}


- (void)updateDigitWidthCache
{
    NSDictionary *attr;
    NSString *tmp;
    CGFloat maxw;
    int i;
    
    attr = [self textAttributes];
    maxw = [@"0" sizeWithAttributes:attr].width;
    for (i=1; i<10; i++) {
        tmp = [NSString stringWithFormat:@"%d", i];
        maxw = MAX(maxw, [tmp sizeWithAttributes:attr].width);
    }
    _maxDigitWidthOfCurrentFont = maxw;
}


- (CGFloat)requiredThickness
{
    NSUInteger lineCount, digits;
    CGFloat stringWidth;
    CGFloat decorationsWidth;
    
    if (_showsLineNumbers) {
        lineCount = [self lineCount] + _startingLineNumber - 1;
        digits = (NSUInteger)log10(lineCount) + 1;
        stringWidth = digits * _maxDigitWidthOfCurrentFont + RULER_MARGIN;
    } else {
        stringWidth = 0;
    }
    
    decorationsWidth = [self decorationColumnWidth];

	// Round up the value. There is a bug on 10.4 where the display gets all
    // wonky when scrolling if you don't return an integral value here.
    return ceil(MAX(_minimumWidth, decorationsWidth + stringWidth + RULER_MARGIN));
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
        if (linenum < [self lineCount]) {
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
    
    // See if we need to adjust the width of the view
    oldThickness = [self ruleThickness];
    newThickness = [self requiredThickness];
    if (fabs(oldThickness - newThickness) >= 1) {
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
    NSRect visibleRect;
    NSLayoutManager	*layoutManager;
    NSTextStorage *ts;
    NSRange range, glyphRange;
    NSUInteger index, line;
    NSRect wholeLineRect;
    CGContextRef drawingContext;
    NSColor *markerColor;

    [self drawBackgroundInRect:dirtyRect];
    
    view = [self clientView];
    visibleRect = [[[self scrollView] contentView] bounds];
    layoutManager = [view layoutManager];
    ts = [layoutManager textStorage];

    drawingContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGAffineTransform flipTransform = {1, 0, 0, -1, 0, 0};
    CGContextSetTextMatrix(drawingContext, flipTransform);

    // Find the characters that are currently visible, make a range,  then fudge the range a tad in case
    // there is an extra new line at end. It doesn't show up in the glyphs so would not be accounted for.
    glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[view textContainer]];
    range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    range.length++;

    for (line = [ts mgs_rowOfCharacter:range.location]; ; line++)
    {
        index = [ts mgs_firstCharacterInRow:line];
        
        if (index == NSNotFound || index > NSMaxRange(range))
            break;
        
        if (NSLocationInRange(index, range))
        {
            wholeLineRect = [self wholeLineRectForLine:line];

            /* Draw line numbers first so that error images won't be buried
             * underneath long line numbers.
             * Line numbers are internally stored starting at 0 */
            if ((markerColor = [_breakpointData objectForKey:@(line + 1)])) {
                [self drawMarkerInRect:wholeLineRect withColor:markerColor];
                if (self.showsLineNumbers)
                    [self drawLineNumber:line inRect:wholeLineRect hasMarker:YES];
            } else {
                if (self.showsLineNumbers)
                    [self drawLineNumber:line inRect:wholeLineRect hasMarker:NO];
            }

            [self drawDecorationOfLine:line];
        }
    }
}


- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    NSRect bounds, visibleRect;
    NSBezierPath *dottedLine;
    NSColor *dotColor, *borderColor;
    const CGFloat dash[2] = {1.0f, 2.0f};
    
    bounds = [self bounds];
    visibleRect = [[[self scrollView] contentView] bounds];
    
    [self.backgroundColor set];
    NSRectFill(bounds);
    
    borderColor = [self.backgroundColor blendedColorWithFraction:.5 ofColor:self.clientView.backgroundColor];
    dotColor = [borderColor blendedColorWithFraction:(2.0*2.0/3.0)-.94 ofColor:[NSColor blackColor]];
    
    dottedLine = [NSBezierPath bezierPath];
    [dottedLine moveToPoint:NSMakePoint(bounds.size.width-0.5, 0)];
    [dottedLine lineToPoint:NSMakePoint(bounds.size.width-0.5, bounds.size.height)];
    
    [borderColor set];
    [dottedLine stroke];
    
    [dotColor set];
    [dottedLine setLineDash:dash count:2 phase:visibleRect.origin.y];
    [dottedLine stroke];
}


/// @param line uses zero-based indexing.
- (void)drawLineNumber:(NSUInteger)line inRect:(NSRect)wholeLineRect hasMarker:(BOOL)marked
{
    CGFloat ypos;
    NSRect bounds;
    NSString *labelText;
    NSAttributedString *drawingAttributedString;
    NSDictionary *currentTextAttributes;
    CGContextRef drawingContext;
    
    drawingContext = [[NSGraphicsContext currentContext] graphicsPort];
    bounds = [self bounds];
    ypos = wholeLineRect.origin.y;
    
    if (marked)
        currentTextAttributes = [self highlightTextAttributesForLine:line];
    else
        currentTextAttributes = [self textAttributes];
    
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


/// @param line uses zero-based indexing.
- (NSRect)wholeLineRectForLine:(NSUInteger)line
{
    id			      view;
    NSRect            visibleRect;
    NSLayoutManager	  *layoutManager;
    NSTextContainer	  *container;
    NSUInteger        index, stringLength;
    NSRect            rect;
    NSRect            wholeLineRect = NSZeroRect;

    view = [self clientView];
    layoutManager = [view layoutManager];
    container = [view textContainer];

    visibleRect = [[[self scrollView] contentView] bounds];
    stringLength = [[view string] length];

    index = [layoutManager.textStorage mgs_firstCharacterInRow:line];

    NSUInteger glyphIdx = [layoutManager glyphIndexForCharacterAtIndex:index];
    if (index < stringLength)
        rect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIdx effectiveRange:NULL];
    else /* Last line */
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


/// @returns zero-based indexing. Never returns NSNotFound
- (NSUInteger)lineNumberForLocation:(CGFloat)location
{
	NSUInteger i;
	NSRect visibleRect;
    SMLTextView *view;
    CGFloat insptdist;
    
	view = [self clientView];
	visibleRect = [[[self scrollView] contentView] bounds];
	location += NSMinY(visibleRect);
    
    i = [view.layoutManager characterIndexForPoint:NSMakePoint(0, location)
          inTextContainer:view.textContainer
          fractionOfDistanceBetweenInsertionPoints:&insptdist];
    /* insptdist is how far the returned character's insertion point is from
     * the insertion point that would appear when clicking on the specified
     * point. 0 means that the user clicked before the character i, and
     * 1 means the user clicked after the character i.*/
    if (insptdist >= 1.0)
        /* Adjust the character index to become the insertion point's index */
        i++;
	return [view.textStorage mgs_rowOfCharacter:i];
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


- (NSUInteger)testHitAtWindowPoint:(NSPoint)p decoration:(MGSGutterHitType *)w trackingRect:(NSRect *)tr
{
    NSPoint location;
    NSUInteger line;
    NSRect trackRect;
    MGSGutterHitType where;
    
    location = [self convertPoint:p fromView:nil];
    if (!CGRectContainsPoint(self.bounds, location)) {
        where = MGSGutterHitTypeOutside;
        trackRect = NSZeroRect;
        line = NSNotFound;
    } else {
        line = [self lineNumberForLocation:location.y];
        where = MGSGutterHitTypeBreakpoint;
        
        if ([_decorations objectForKey:@(line+1)]) {
            trackRect = [self decorationRectOfLine:line];
            if (CGRectContainsPoint(trackRect, location))
                where = MGSGutterHitTypeDecoration;
        }
        if (where == MGSGutterHitTypeBreakpoint)
            trackRect = [self wholeLineRectForLine:line];
    }
    
    if (w)
        *w = where;
    if (tr)
        *tr = trackRect;
    return line;
}


- (void)mouseDown:(NSEvent *)theEvent
{
    NSUInteger line;
    MGSGutterHitType where;
    NSRect tr;
    
    if ([theEvent buttonNumber] != 0) {
        _mouseDownLineTracking = NSNotFound;
        return;
    }
    
    line = [self testHitAtWindowPoint:theEvent.locationInWindow decoration:&where trackingRect:&tr];
    
    if (line != NSNotFound) {
        _lastHitPosition = where;
        _mouseDownLineTracking = line;
        _mouseDownRectTracking = tr;
        
        if (where == MGSGutterHitTypeBreakpoint)
            [self breakpointClickedOnLine:_mouseDownLineTracking+1];
    } else
        _mouseDownLineTracking = NSNotFound;
}


- (void)mouseUp:(NSEvent *)theEvent
{
    NSUInteger line;
    MGSGutterHitType where;
    NSRect tr;
    
    if ([theEvent buttonNumber] != 0)
        return;
    
    if (_mouseDownLineTracking == NSNotFound)
        return;
    
    line = [self testHitAtWindowPoint:theEvent.locationInWindow decoration:&where trackingRect:&tr];
    if (CGRectEqualToRect(tr, _mouseDownRectTracking)) {
        if (where == _lastHitPosition && where == MGSGutterHitTypeDecoration) {
            _selectedLineNumber = _mouseDownLineTracking;
            [NSApp sendAction:_decorationActionSelector to:_decorationActionTarget from:self];
        }
    } else {
        if (_lastHitPosition == MGSGutterHitTypeBreakpoint)
            [self breakpointClickedOnLine:_mouseDownLineTracking+1];
    }
}


- (NSMenu *)menuForEvent:(NSEvent *)event
{
    NSUInteger line;
    MGSGutterHitType where;
    
    if ([event buttonNumber] != 0)
        _mouseDownLineTracking = NSNotFound;
    
    line = [self testHitAtWindowPoint:event.locationInWindow decoration:&where trackingRect:NULL];
    if (line != NSNotFound) {
        if (where == MGSGutterHitTypeBreakpoint && _breakpointDelegate)
            return [_breakpointDelegate menuForBreakpointInLine:line+1 ofFragaria:_fragaria];
    }
    return [super menuForEvent:event];
}


#pragma mark - Delegate handling


- (void)reloadBreakpointData
{
    NSMutableDictionary *data;
    NSSet *linesWithBreakpoints;
    id tmp;
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
        tmp = [_breakpointDelegate breakpointsForFragaria:self.fragaria];
        if ([tmp isKindOfClass:[NSIndexSet class]]) {
            linesWithBreakpoints = [[NSSet alloc] mgs_initWithIndexSet:tmp];
        } else if ([tmp isKindOfClass:[NSSet class]]) {
            linesWithBreakpoints = tmp;
        } else {
            [NSException raise:@"MGSBrokenBreakpointDelegate" format:@"The "
             "breakpoint delegate %@ of %@ returned an object which is not an "
             "NSSet or an NSIndexSet, from the -breakpointsForFragaria: method.",
             _breakpointDelegate, self];
        }
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
