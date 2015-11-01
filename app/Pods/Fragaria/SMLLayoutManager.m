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

#import "SMLLayoutManager.h"


#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100
typedef NSInteger NSUnderlineStyle;
#endif


typedef enum : NSUInteger {
    kTabLine = 0,
    kSpaceLine = 1,
    kNewLineLine = 2
} MGSLineCacheIndex;


#define kSMLSquiggleAmplitude (3.0)
#define kSMLSquigglePeriod    (6.0)
#define kSMLSquigglePhase     (-1.5)


static CGFloat SquiggleFunction(CGFloat x) {
    CGFloat px, ix;
    CGFloat y;
    
    px = modf((x + kSMLSquigglePhase) / kSMLSquigglePeriod, &ix);
    y = px < 0.5 ? px : 1.0 - px;
    return (y - 0.25) * 2.0 * kSMLSquiggleAmplitude;
}



@implementation SMLLayoutManager {
    NSMutableArray *lineRefs;
}


@synthesize showsInvisibleCharacters = _showsInvisibleCharacters;


#pragma mark - Instance methods

/*
 * - init
 */
- (id)init
{
    self = [super init];
	if (self) {
        _invisibleCharactersFont = [NSFont fontWithName:@"Menlo" size:11];
        _invisibleCharactersColour = [NSColor orangeColor];
        
        [self resetAttributesAndGlyphs];
        
		[self setAllowsNonContiguousLayout:YES]; // Setting this to YES sometimes causes "an extra toolbar" and other graphical glitches to sometimes appear in the text view when one sets a temporary attribute, reported as ID #5832329 to Apple
	}
	return self;
}


#pragma mark - Drawing

/*
 * - drawGlyphsForGlyphRange:atPoint:
 */
- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{
    if (self.showsInvisibleCharacters) {
        
		NSPoint pointToDrawAt;
		NSRect glyphFragment;
		NSString *completeString = [[self textStorage] string];
		NSInteger lengthToRedraw = NSMaxRange(glyphRange);
        
        void *gcContext = [[NSGraphicsContext currentContext] graphicsPort];
        
        // see http://www.cocoabuilder.com/archive/cocoa/242724-ctlinecreatewithattributedstring-ignoring-font-size.html
        
        // if our context is flipped then we need to flip our drawn text too
        CGAffineTransform t = {1.0, 0.0, 0.0, -1.0, 0.0, 0.0};
        if (![[NSGraphicsContext currentContext] isFlipped]) {
            t = CGAffineTransformIdentity;
        }
        CGContextSetTextMatrix (gcContext, t);
    
        // we may not have any glyphs generated at this stage
		for (NSInteger idx = glyphRange.location; idx < lengthToRedraw; idx++) {
			unichar characterToCheck = [completeString characterAtIndex:idx];
            NSUInteger lineRefIndex = 0;
            
			if (characterToCheck == '\t') {
                lineRefIndex = kTabLine;
            } else if (characterToCheck == ' ') {
                lineRefIndex = kSpaceLine;
			} else if (characterToCheck == '\n' || characterToCheck == '\r') {
                lineRefIndex = kNewLineLine;
			} else {
                continue;
            }
            
            // http://lists.apple.com/archives/cocoa-dev/2012/Sep/msg00531.html
            //
            // Draw profiling indicated that the CoreText approach on 10.8 is an order of magnitude
            // faster that using the NSStringDrawing methods.
        
            pointToDrawAt = [self locationForGlyphAtIndex:idx];
            glyphFragment = [self lineFragmentRectForGlyphAtIndex:idx effectiveRange:NULL];
            
            // get our text line object
            CTLineRef line = (__bridge CTLineRef)[lineRefs objectAtIndex:lineRefIndex];
            
            pointToDrawAt.x += glyphFragment.origin.x;
            
            /* Some control glyphs have zero size (newlines), and if they are
             * not placed before a non-zero-sized glyph the typesetter simply
             * sticks them at the bottom of the line fragment rect. In these
             * cases we have to correct the location where we draw, otherwise
             * the visible character will be placed too low on the line. */
            if (pointToDrawAt.y >= glyphFragment.size.height) {
                CGFloat descent, leading;
                CTLineGetTypographicBounds(line, NULL, &descent, &leading);
                pointToDrawAt.y = NSMaxY(glyphFragment) - floor(descent+0.5) - floor(leading+0.5);
            } else {
                pointToDrawAt.y += glyphFragment.origin.y;
            }
            
            // draw with cached core text line ref
            CGContextSetTextPosition(gcContext, pointToDrawAt.x, pointToDrawAt.y);
            CTLineDraw(line, gcContext);
		}
    }
    
    // the following causes glyph generation to occur if required
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];
}


#pragma mark - Accessors


/*
 * - attributedStringWithTemporaryAttributesApplied
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	/*
	 
	 temporary attributes have been applied by the layout manager to
	 syntax colour the text.
	 
	 to retain these we duplicate the text and apply the temporary attributes as normal attributes
	 
	 */
	
	NSMutableAttributedString *attributedString = [[self attributedString] mutableCopy];
	NSInteger lastCharacter = [attributedString length];
	[self removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, lastCharacter)];
	
	NSInteger idx = 0;
	while (idx < lastCharacter) {
		NSRange range = NSMakeRange(0, 0);
		NSDictionary *tempAttributes = [self temporaryAttributesAtCharacterIndex:idx effectiveRange:&range];
		if ([tempAttributes count] != 0) {
			[attributedString setAttributes:tempAttributes range:range];
		}
		NSInteger rangeLength = range.length;
		if (rangeLength != 0) {
			idx = idx + rangeLength;
		} else {
			idx++;
		}
	}
	
	return attributedString;	
}


#pragma mark - Property Accessors


/*
 * @property textFont
 */
-(void)setInvisibleCharactersFont:(NSFont *)textFont
{
    _invisibleCharactersFont = textFont;
    [self resetAttributesAndGlyphs];
    [[self firstTextView] setNeedsDisplay:YES];

}


/*
 * @property textInvisibleCharactersColor
 */
- (void)setInvisibleCharactersColour:(NSColor *)textInvisibleCharactersColour
{
    _invisibleCharactersColour = textInvisibleCharactersColour;
    [self resetAttributesAndGlyphs];
    [[self firstTextView] setNeedsDisplay:YES];
}


/*
 * @property showInvisibleCharacters
 */
- (void)setShowsInvisibleCharacters:(BOOL)showsInvisibleCharacters
{
    _showsInvisibleCharacters = showsInvisibleCharacters;
    [[self firstTextView] setNeedsDisplay:YES];
}

- (BOOL)showsInvisibleCharacters
{
    return _showsInvisibleCharacters;
}


#pragma mark - Syntax Error Underlining


- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange
                     underlineType:(NSUnderlineStyle)underlineVal
                    baselineOffset:(CGFloat)baselineOffset
                  lineFragmentRect:(NSRect)lineRect
            lineFragmentGlyphRange:(NSRange)lineGlyphRange
                   containerOrigin:(NSPoint)containerOrigin
{
    NSRect gr;
    NSTextContainer *tc;
    CGFloat yzero;
    NSPoint pos;
    NSBezierPath *bp;
    
    if ((underlineVal & 0x0F) != MGSUnderlineStyleSquiggly) {
        [super drawUnderlineForGlyphRange:glyphRange underlineType:underlineVal baselineOffset:baselineOffset lineFragmentRect:lineRect lineFragmentGlyphRange:lineGlyphRange containerOrigin:containerOrigin];
        return;
    }
    
    tc = [self textContainerForGlyphAtIndex:glyphRange.location effectiveRange:NULL];
    gr = [self boundingRectForGlyphRange:glyphRange inTextContainer:tc];
    bp = [NSBezierPath bezierPath];
    
    yzero = NSMaxY(gr) - baselineOffset / 2.0;
    pos.x = gr.origin.x;
    pos.y = SquiggleFunction(pos.x) + yzero;
    [bp moveToPoint:pos];
    
    pos.x = ceil((pos.x + kSMLSquigglePhase) / (kSMLSquigglePeriod / 2));
    pos.x = pos.x * (kSMLSquigglePeriod / 2) - kSMLSquigglePhase;
    while (pos.x < NSMaxX(gr)) {
        pos.y = SquiggleFunction(pos.x) + yzero;
        [bp lineToPoint:pos];
        pos.x += kSMLSquigglePeriod / 2;
    }
    pos.x = NSMaxX(gr);
    pos.y = SquiggleFunction(pos.x) + yzero;
    [bp lineToPoint:pos];
    
    [[NSColor redColor] setStroke];
    [bp stroke];
}


#pragma mark - Class extension


/*
 * - resetAttributesAndGlyphs
 */
- (void)resetAttributesAndGlyphs
{
    NSDictionary *defAttributes;
    NSString *tabCharacter;
    NSString *newLineCharacter;
    NSString *spaceCharacter;
    
    // assemble our default attributes
    defAttributes = @{NSFontAttributeName: self.invisibleCharactersFont,
      NSForegroundColorAttributeName: self.invisibleCharactersColour};

    // define substitute characters for whitespace chars
    tabCharacter = @"\u21E2";
    newLineCharacter = @"\u00B6";
    spaceCharacter = @"\u22C5";
    
    // all CFTypes can be added to NS collections
    // http://www.mikeash.com/pyblog/friday-qa-2010-01-22-toll-free-bridging-internals.html
    lineRefs = [NSMutableArray arrayWithCapacity:kNewLineLine+1];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:tabCharacter attributes:defAttributes];
    CTLineRef textLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    [lineRefs addObject:(__bridge id)textLine]; // kTabLine
    CFRelease(textLine);
    
    attrString = [[NSAttributedString alloc] initWithString:spaceCharacter attributes:defAttributes];
    textLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    [lineRefs addObject:(__bridge id)textLine]; // kSpaceLine
    CFRelease(textLine);
    
    attrString = [[NSAttributedString alloc] initWithString:newLineCharacter attributes:defAttributes];
    textLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    [lineRefs addObject:(__bridge id)textLine]; // kNewLineLine
    CFRelease(textLine);
}


@end
