/*
 
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "MGSFragariaFramework.h"
#import "SMLLayoutManager.h"

typedef enum {
    kTabLine = 0,
    kSpaceLine = 1,
    kNewLineLine = 2
} MGSLineCacheIndex;

@interface SMLLayoutManager()
- (void)resetAttributesAndGlyphs;
@end

@implementation SMLLayoutManager

@synthesize showInvisibleCharacters;

#pragma mark -
#pragma mark Instance methods
/*
 
 - init
 
 */
- (id)init
{
    self = [super init];
	if (self) {
		
        invisibleGlyphs = NULL;
        
        // experimental glyph substitution can be enabled with useGlyphSubstitutionForInvisibleGlyphs = YES
        useGlyphSubstitutionForInvisibleGlyphs = NO;
        
        // draw inivisble glyphs using core text
        drawInvisibleGlyphsUsingCoreText = YES;
        
        [self resetAttributesAndGlyphs];
        
		[self setShowInvisibleCharacters:[[SMLDefaults valueForKey:MGSFragariaPrefsShowInvisibleCharacters] boolValue]];
		[self setAllowsNonContiguousLayout:YES]; // Setting this to YES sometimes causes "an extra toolbar" and other graphical glitches to sometimes appear in the text view when one sets a temporary attribute, reported as ID #5832329 to Apple
		
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        
        // text font and colour preferences
		[defaultsController addObserver:self forKeyPath:@"values.FragariaTextFont" options:NSKeyValueObservingOptionNew context:@"FontOrColourValueChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaInvisibleCharactersColourWell" options:NSKeyValueObservingOptionNew context:@"FontOrColourValueChanged"];
        
        // invisible characters preference
        [defaultsController addObserver:self forKeyPath:@"values.FragariaShowInvisibleCharacters" options:NSKeyValueObservingOptionNew context:@"InvisibleCharacterValueChanged"];
        
        
        // assign our custom glyph generator
        if (useGlyphSubstitutionForInvisibleGlyphs) {
            [self setGlyphGenerator:[[MGSGlyphGenerator alloc] init]];
        }

	}
	return self;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(__bridge NSString *)context isEqualToString:@"FontOrColourValueChanged"]) {
		[self resetAttributesAndGlyphs];
		[[self firstTextView] setNeedsDisplay:YES];
    } else if ([(__bridge NSString *)context isEqualToString:@"InvisibleCharacterValueChanged"]) {
        [self setShowInvisibleCharacters:[[SMLDefaults valueForKey:MGSFragariaPrefsShowInvisibleCharacters] boolValue]];
        
        if (useGlyphSubstitutionForInvisibleGlyphs) {
            // we need to regenerate the glyph cache
            [self replaceTextStorage:[self textStorage]];
        }
		[[self firstTextView] setNeedsDisplay:YES];

        
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark -
#pragma mark Glyph handling

#pragma mark -
#pragma mark Drawing

/*
 
 - drawGlyphsForGlyphRange:atPoint:
 
 */
- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{

// uncomment below to enable draw profiling
//#define MGS_PROFILE_DRAW
    
#ifdef MGS_PROFILE_DRAW
NSDate *methodStart = [NSDate date];

NSUInteger drawLoopMax = 100;
NSUInteger drawLoop = drawLoopMax;
do {
        
#endif
        
    if (showInvisibleCharacters && !useGlyphSubstitutionForInvisibleGlyphs) {
        
		NSPoint pointToDrawAt;
		NSRect glyphFragment;
		NSString *completeString = [[self textStorage] string];
		NSInteger lengthToRedraw = NSMaxRange(glyphRange);
        
        void *gcContext = [[NSGraphicsContext currentContext] graphicsPort];
        
        if (drawInvisibleGlyphsUsingCoreText) {
                
            // see http://www.cocoabuilder.com/archive/cocoa/242724-ctlinecreatewithattributedstring-ignoring-font-size.html
            
            // if our context is flipped then we need to flip our drawn text too
            CGAffineTransform t = {1.0, 0.0, 0.0, -1.0, 0.0, 0.0};
            if (![[NSGraphicsContext currentContext] isFlipped]) {
                t = CGAffineTransformIdentity;
            }
            CGContextSetTextMatrix (gcContext, t);
        }
    
        // we may not have any glyphs generated at this stage
		for (NSInteger idx = glyphRange.location; idx < lengthToRedraw; idx++) {
			unichar characterToCheck = [completeString characterAtIndex:idx];
            NSUInteger lineRefIndex = 0;
            NSString *subCharacter = nil;
            
			if (characterToCheck == '\t') {
                lineRefIndex = kTabLine;
                subCharacter = tabCharacter;
            } else if (characterToCheck == ' ') {
                lineRefIndex = kSpaceLine;
                subCharacter = spaceCharacter;
			} else if (characterToCheck == '\n' || characterToCheck == '\r') {
                lineRefIndex = kNewLineLine;
                subCharacter = newLineCharacter;
			} else {
                continue;
            }
            
            pointToDrawAt = [self locationForGlyphAtIndex:idx];
            glyphFragment = [self lineFragmentRectForGlyphAtIndex:idx effectiveRange:NULL];
            
            
            // for some fonts the invisible characters are lower on the line than expected
            // when drawing with  -drawAtPoint:withAttributes:
            //
            // experimental glyph substituion is available with useGlyphSubstitutionForInvisibleGlyphs = YES;
            //[outputChar drawAtPoint:pointToDrawAt withAttributes:defAttributes];
            //
            // see thread
            //
            // http://lists.apple.com/archives/cocoa-dev/2012/Sep/msg00531.html
            //
            // Draw profiling indicated that the CoreText approach on 10.8 is an order of magnitude
            // faster that using the NSStringDRawing methods.

            if (drawInvisibleGlyphsUsingCoreText) {
                
                // draw with cached core text line ref
                pointToDrawAt.x += glyphFragment.origin.x;
                pointToDrawAt.y += glyphFragment.origin.y;
                
                // get our text line object
                CTLineRef line = (__bridge CTLineRef)[lineRefs objectAtIndex:lineRefIndex];
                
                CGContextSetTextPosition(gcContext, pointToDrawAt.x, pointToDrawAt.y);
                CTLineDraw(line, gcContext);
           } else {
               
               // draw with NSString
               glyphFragment.origin.x += pointToDrawAt.x;
               glyphFragment.origin.y += pointToDrawAt.y;
               
               [subCharacter drawWithRect:glyphFragment options:0 attributes:defAttributes];
           }
            
		}
    }
    
// profile invisible glyph drawing
#ifdef MGS_PROFILE_DRAW
    
    drawLoop--;
} while (drawLoop);

    

    NSDate *methodFinish = [NSDate date];
    
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    static NSTimeInterval totalExecutionTime = 0;
    static NSUInteger drawCount = 0;
    
    drawCount++;
    totalExecutionTime += executionTime;
    NSTimeInterval avgExecutionTime = totalExecutionTime / drawCount;
    
    NSLog(@"(%d) avg invisible glyph draw (looped %d) time = %f", drawCount, drawLoopMax, avgExecutionTime);
#endif
    
    // the following causes glyph generation to occur if required
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];


}

/*
 
 - insertGlyphs:length:forStartingGlyphAtIndex:characterIndex:
 
 */
- (void)insertGlyphs:(const NSGlyph *)glyphs
              length:(NSUInteger)length
forStartingGlyphAtIndex:(NSUInteger)glyphIndex
      characterIndex:(NSUInteger)charIndex
{
    /*
     
     This method is called by the NSGlyphGenerator with chunks of glyphs 
     each index of which correspond to a character in the text storage.
     
     This method is called lazily to generate glyphs as required for display
     
     Glyph substitution causes tabbing to break at present.
     Plus line end characters are not rendered.
     Colourisation is also made more difficult.
     
     Left this method in for now as the approach may be useful in the future
     
     */
    
    if (showInvisibleCharacters && useGlyphSubstitutionForInvisibleGlyphs) {
        NSString *textString = [[self attributedString] string];
    
        for (NSUInteger i = 0; i < length; i++) {

            unichar characterToCheck = [textString characterAtIndex:charIndex + i];
            NSUInteger inivisbleGlyphIndex = 0;

            // glyph filter
            if (characterToCheck == '\t') {
                inivisbleGlyphIndex = 0;
            } else if (characterToCheck == ' ') {
                inivisbleGlyphIndex = 1;
            } else if (characterToCheck == '\n' || characterToCheck == '\r') {
                inivisbleGlyphIndex = 2;
            } else {
                continue;
            }

            // insert new glyph
            ((NSGlyph *)glyphs)[i] = invisibleGlyphs[inivisbleGlyphIndex];
        }

    }
    [super insertGlyphs:glyphs
                        length:length
       forStartingGlyphAtIndex:glyphIndex
                characterIndex:charIndex];
}

/*
 
 - showCGGlyphs:positions:count:font:matrix:attributes:inContext:
 
 */
- (void)showCGGlyphs:(const CGGlyph *)glyphs positions:(const NSPoint *)positions count:(NSUInteger)glyphCount font:(NSFont *)font matrix:(NSAffineTransform *)textMatrix attributes:(NSDictionary *)attributes inContext:(NSGraphicsContext *)graphicsContext
{
    // customise glyph drawing here
    [super showCGGlyphs:glyphs positions:positions count:glyphCount font:font matrix:textMatrix attributes:attributes inContext:graphicsContext];

}

#pragma mark -
#pragma mark Accessors


/*
 
 - attributedStringWithTemporaryAttributesApplied
 
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

#pragma mark -
#pragma mark Class extension

- (void)resetAttributesAndGlyphs
{
    // assemble our default attributes
    defAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                  [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]], NSFontAttributeName, [NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsInvisibleCharactersColourWell]], NSForegroundColorAttributeName, nil];

    // define substitute characters for whitespace chars
    unichar tabUnichar = 0x00AC;
    tabCharacter = [[NSString alloc] initWithCharacters:&tabUnichar length:1];
    unichar newLineUnichar = 0x00B6;
    newLineCharacter = [[NSString alloc] initWithCharacters:&newLineUnichar length:1];
    spaceCharacter = @".";
    
    if (drawInvisibleGlyphsUsingCoreText) {
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
    
    // experimental glyph substitution
    if (useGlyphSubstitutionForInvisibleGlyphs) {

        NSString *glyphString = [NSString stringWithFormat:@"%@%@%@", tabCharacter, spaceCharacter, newLineCharacter];
        
        // use NSLayoutManager instance to generate required glyphs using the default attributes
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:glyphString];
        [textStorage setAttributes:defAttributes range:NSMakeRange(0, [glyphString length])];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *textContainer = [[NSTextContainer alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        
        // cache the invisible glyphs
        if (invisibleGlyphs == NULL) {
            invisibleGlyphs = malloc(sizeof(NSGlyph) * [glyphString length] + 1);
        }
        [layoutManager getGlyphs:invisibleGlyphs range:NSMakeRange(0, [glyphString length])];
    }
}
@end
