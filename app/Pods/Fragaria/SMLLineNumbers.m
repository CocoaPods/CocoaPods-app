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

#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

@interface SMLLineNumbers()
@property (strong) NSDictionary *attributes;
@property (strong) id document;
@property (strong) NSClipView *updatingLineNumbersForClipView;
@property BOOL shouldHandleBoundsChange;

@end

@implementation SMLLineNumbers

@synthesize attributes, document, updatingLineNumbersForClipView;

#pragma mark -
#pragma mark Instance methods
/*
 
 - init
 
 */
- (id)init
{
	self = [self initWithDocument:nil];
	
	return self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}

/*
 
 - initWithDocument:
 
 */
- (id)initWithDocument:(id)theDocument
{
	if ((self = [super init])) {
		
		self.document = theDocument;
		zeroPoint = NSMakePoint(0, 0);
    _startingLineNumber = 0;
    _numberOfVisibleLines = 0;
		_shouldHandleBoundsChange = YES;
    
		self.attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]], NSFontAttributeName, nil];
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaTextFont" options:NSKeyValueObservingOptionNew context:@"TextFontChanged"];
	}
	
    return self;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(__bridge NSString *)context isEqualToString:@"TextFontChanged"]) {
		self.attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]], NSFontAttributeName, nil];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark View updating
/*
 
 - viewBoundsDidChange:
 
 */
- (void)viewBoundsDidChange:(NSNotification *)notification
{
	if (notification != nil && [notification object] != nil && [[notification object] isKindOfClass:[NSClipView class]]) {
		[self updateLineNumbersForClipView:[notification object] checkWidth:YES recolour:YES];
	}
}

/*
 
 - updateLineNumbersCheckWidth:recolour:
 
 */
- (void)updateLineNumbersCheckWidth:(BOOL)checkWidth recolour:(BOOL)recolour
{
	[self updateLineNumbersForClipView:[[document valueForKey:ro_MGSFOScrollView] contentView] checkWidth:checkWidth recolour:recolour];
}

/*
 
 - updateLineNumbersForClipView:checkWidth:recolour:
 
 */
- (void)updateLineNumbersForClipView:(NSClipView *)clipView checkWidth:(BOOL)checkWidth recolour:(BOOL)recolour
{
  if (!self.shouldHandleBoundsChange)
    return;
  
  self.shouldHandleBoundsChange = NO;
  
	NSScrollView *gutterScrollView = nil;
	NSInteger idx = 0;
	NSInteger lineNumber = 0;
	NSRange range = NSMakeRange(0, 0);
	NSInteger gutterWidth = 0;
	NSRect currentViewBounds = NSZeroRect;
	
	NSInteger currentLineHeight;
	
	CGFloat addToScrollPoint;
	
	if (self.updatingLineNumbersForClipView == clipView) {
    self.shouldHandleBoundsChange = YES;
		return;
	}
	self.updatingLineNumbersForClipView = clipView;
	_numberOfVisibleLines = 0;
  
	SMLTextView *textView = [clipView documentView];
	
	if ([[document valueForKey:MGSFOShowLineNumberGutter] boolValue] == NO || textView == nil) {
		if (checkWidth == YES && recolour == YES) {
			[[document valueForKey:ro_MGSFOSyntaxColouring] pageRecolourTextView:textView];
		}
    self.updatingLineNumbersForClipView = nil;
    self.shouldHandleBoundsChange = YES;
    return;
	}
	
	NSScrollView *scrollView = (NSScrollView *)[clipView superview];
	addToScrollPoint = 0;	
	if (scrollView == [document valueForKey:ro_MGSFOScrollView]) {
		gutterScrollView = [document valueForKey:ro_MGSFOGutterScrollView];
	} else {
    self.updatingLineNumbersForClipView = nil;
    self.shouldHandleBoundsChange = YES;
    return;
	}
    
    // get break points from delegate
    NSSet* breakpoints = NULL;
    id breakpointDelegate = [[MGSFragaria currentInstance] objectForKey:MGSFOBreakpointDelegate];
    if (breakpointDelegate && [breakpointDelegate respondsToSelector:@selector(breakpointsForFile:)])
    {
        breakpoints = [breakpointDelegate breakpointsForFile:[gutterScrollView.documentView fileName]];
    }
	
	NSLayoutManager *layoutManager = [textView layoutManager];
	NSRect visibleRect = [[scrollView contentView] documentVisibleRect];
	NSRange visibleRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
	NSString *textString = [textView string];
	NSString *searchString = [textString substringWithRange:NSMakeRange(0,visibleRange.location)];
	
	for (idx = 0, lineNumber = 0; idx < (NSInteger)visibleRange.location; lineNumber++) {
		idx = NSMaxRange([searchString lineRangeForRange:NSMakeRange(idx, 0)]);
	}
	
	NSInteger indexNonWrap = [searchString lineRangeForRange:NSMakeRange(idx, 0)].location;
	NSInteger maxRangeVisibleRange = NSMaxRange([textString lineRangeForRange:NSMakeRange(NSMaxRange(visibleRange), 0)]); // Set it to just after the last glyph on the last visible line
	NSInteger numberOfGlyphsInTextString = [layoutManager numberOfGlyphs];
	BOOL oneMoreTime = NO;
	if (numberOfGlyphsInTextString != 0) {
		unichar lastGlyph = [textString characterAtIndex:numberOfGlyphsInTextString - 1];
		if (lastGlyph == '\n' || lastGlyph == '\r') {
			oneMoreTime = YES; // Continue one more time through the loop if the last glyph isn't newline
		}
	}
	NSMutableString *lineNumbersString = [[NSMutableString alloc] init];
	
    int textLine = 0;
    NSMutableArray* textLineBreakpoints = [NSMutableArray array];
    
    // generate line number string
	while (indexNonWrap <= maxRangeVisibleRange) {
        
        // wrap or not
		if (idx == indexNonWrap) {
			lineNumber++;
			_numberOfVisibleLines++;
      
			[lineNumbersString appendFormat:@"%li\n", (long)(lineNumber + _startingLineNumber)];
            textLine++;
            
            // flag breakpoints
            if ([breakpoints containsObject:[NSNumber numberWithInt:(int)lineNumber]])
            {
                [textLineBreakpoints addObject:[NSNumber numberWithInt:textLine]];
            }
		} else {
			[lineNumbersString appendFormat:@"%C\n", (unsigned short)0x00B7];
			indexNonWrap = idx;
            textLine++;
		}
		
		if (idx < maxRangeVisibleRange) {
			[layoutManager lineFragmentRectForGlyphAtIndex:idx effectiveRange:&range];
			idx = NSMaxRange(range);
			indexNonWrap = NSMaxRange([textString lineRangeForRange:NSMakeRange(indexNonWrap, 0)]);
		} else {
			idx++;
			indexNonWrap ++;
		}
		
		if (idx == numberOfGlyphsInTextString && !oneMoreTime) {
			break;
		}
	}
	
    // check width is okay
	if (checkWidth == YES) {
		NSInteger widthOfStringInGutter = [lineNumbersString sizeWithAttributes:self.attributes].width;
		
		if (widthOfStringInGutter > ([[document valueForKey:MGSFOGutterWidth] integerValue] - 14)) { // Check if the gutterTextView has to be resized
			[document setValue:[NSNumber numberWithInteger:widthOfStringInGutter + 20] forKey:MGSFOGutterWidth]; // Make it bigger than need be so it doesn't have to resized soon again
			if ([[document valueForKey:MGSFOShowLineNumberGutter] boolValue] == YES) {
				gutterWidth = [[document valueForKey:MGSFOGutterWidth] integerValue];
			} else {
				gutterWidth = 0;
			}
			currentViewBounds = [[gutterScrollView superview] bounds];
			[scrollView setFrame:NSMakeRect(gutterWidth, 0, currentViewBounds.size.width - gutterWidth, currentViewBounds.size.height)];
			
			[gutterScrollView setFrame:NSMakeRect(0, 0, [[document valueForKey:MGSFOGutterWidth] integerValue], currentViewBounds.size.height)];
		}
	}
	
	if (recolour == YES) {
		[[document valueForKey:ro_MGSFOSyntaxColouring] pageRecolourTextView:textView];
	}
	
	// Fix flickering while rubber banding: Only change the text, if NOT rubber banding.
	if (visibleRect.origin.y >= 0.0f && visibleRect.origin.y <= textView.frame.size.height - visibleRect.size.height) {
		[[gutterScrollView documentView] setString:lineNumbersString];
    }
    
    // set breakpoint lines
    [[gutterScrollView documentView] setBreakpointLines:textLineBreakpoints];
	   
	[[gutterScrollView contentView] setBoundsOrigin:zeroPoint]; // To avert an occasional bug which makes the line numbers disappear
	currentLineHeight = (NSInteger)[textView lineHeight];
	if ((NSInteger)visibleRect.origin.y != 0 && currentLineHeight != 0) {
		CGFloat y = ((NSInteger)visibleRect.origin.y % currentLineHeight) + addToScrollPoint;  // Align the line numbers with the text.
		
		// Don't align, but directly calculate the offset, when rubber banding.
		if (visibleRect.origin.y < 0.0f)
			y = visibleRect.origin.y;
		else if (visibleRect.origin.y > textView.frame.size.height - visibleRect.size.height)
			y = visibleRect.origin.y - (textView.frame.size.height - visibleRect.size.height);
		
		[[gutterScrollView contentView] scrollToPoint:NSMakePoint(0, y)];
	}
	
	self.updatingLineNumbersForClipView = nil;
  self.shouldHandleBoundsChange = YES;
}

/*
 
 - setStartingLineNumber:
 
 */
- (void)setStartingLineNumber:(NSUInteger)value {
  _startingLineNumber = value;
  [self updateLineNumbersForClipView:[[document valueForKey:ro_MGSFOScrollView] contentView] checkWidth:YES recolour:YES];
}

/*
 
 - startingLineNumber:
 
 */
- (NSUInteger)startingLineNumber {
  return _startingLineNumber;
}

/*
 
 - numberOfVisibleLines:
 
 */
- (NSUInteger)numberOfVisibleLines {
  return _numberOfVisibleLines;
}

@end
