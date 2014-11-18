/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
 Based on:
 
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

@implementation SMLGutterTextView

@synthesize fileName, breakpointLines;

#pragma mark -
#pragma mark Instance methods
/*
 
 - initWithFrame:
 
 */
- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
        
        imgBreakpoint0 = [MGSFragaria imageNamed:@"editor-breakpoint-0.png"];
        [imgBreakpoint0 setFlipped:YES];
        imgBreakpoint1 = [MGSFragaria imageNamed:@"editor-breakpoint-1.png"];
        [imgBreakpoint1 setFlipped:YES];
        imgBreakpoint2 = [MGSFragaria imageNamed:@"editor-breakpoint-2.png"];
        [imgBreakpoint2 setFlipped:YES];

		[self setContinuousSpellCheckingEnabled:NO];
		[self setAllowsUndo:NO];
		[self setAllowsDocumentBackgroundColorChange:NO];
		[self setRichText:NO];
		[self setUsesFindPanel:NO];
		[self setUsesFontPanel:NO];
		[self setAlignment:NSRightTextAlignment];
		[self setEditable:NO];
		[self setSelectable:NO];
		[[self textContainer] setContainerSize:NSMakeSize([[SMLDefaults valueForKey:MGSFragariaPrefsGutterWidth] integerValue], FLT_MAX)];
		[self setVerticallyResizable:YES];
		[self setHorizontallyResizable:YES];
		[self setAutoresizingMask:NSViewHeightSizable];
		
        // TODO:
        if (NO) {
            /* vlidholt/fragaria adopts this approach to try and improve line number accuracy.
             
              Not sure if this the answer to the EOF line number alignment issue.
             
              These settings would need to respond to changes in font / size and be replicated in the SMLTextView.
             
              Think about it.
             
              The issue may be more to do with positioning the gutter scrcoll view.
              Does line wrapping make the issue worse?
             
             */
            NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
            [style setAlignment:NSRightTextAlignment];
            [style setLineSpacing:1.0];
            [style setMinimumLineHeight:11.0];
            [style setMaximumLineHeight:11.0];
            [self setDefaultParagraphStyle:style];
            
            [self  setTypingAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                         [self defaultParagraphStyle], NSParagraphStyleAttributeName,
                                         nil]];
        }
        
		[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]]];
		[self setTextColor:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsGutterTextColourWell]]];
		[self setInsertionPointColor:[NSColor textColor]];

		[self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.94f alpha:1.0f]];

		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaTextFont" options:NSKeyValueObservingOptionNew context:@"TextFontChanged"];
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
	if ([(__bridge NSString *)context isEqualToString:@"TextFontChanged"]) {
		[self setFont:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsTextFont]]];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark Drawing

/*
 
 - drawRect:
 
 */
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	NSRect bounds = [self bounds]; 
	if ([self needsToDrawRect:NSMakeRect(bounds.size.width - 1, 0, 1, bounds.size.height)] == YES) {
		[[NSColor lightGrayColor] set];
		NSBezierPath *dottedLine = [NSBezierPath bezierPathWithRect:NSMakeRect(bounds.size.width, 0, 0, bounds.size.height)];
		CGFloat dash[2];
		dash[0] = 1.0f;
		dash[1] = 2.0f;
		[dottedLine setLineDash:dash count:2 phase:1.0f];
		[dottedLine stroke];
	}
    
    // draw breakpoints
    if (self.breakpointLines)
    {
        for (NSNumber* lineNumber in self.breakpointLines)
        {
            int line = [lineNumber intValue];
            NSDrawThreePartImage(NSMakeRect(2, line * 13 - 12, bounds.size.width -4, 12), imgBreakpoint0, imgBreakpoint1, imgBreakpoint2, NO, NSCompositeSourceOver, 1, NO);
        }
    }
}

/*
 
 - mouseDown:
 
 */
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSLayoutManager* lm = [self layoutManager];
    NSUInteger glyphIdx = [lm glyphIndexForPoint:curPoint inTextContainer:self.textContainer];
    
    NSUInteger charIdx = [lm characterIndexForGlyphAtIndex:glyphIdx];
    
    NSString* text = [self string];
    NSRange lineRange = [text lineRangeForRange:NSMakeRange(charIdx, 1)];
    NSString* substring = [text substringWithRange:lineRange];
    
    int lineNum = [substring intValue];
    
    id delegate = [[MGSFragaria currentInstance] objectForKey:MGSFOBreakpointDelegate];
    if (delegate && [delegate respondsToSelector:@selector(toggleBreakpointForFile:onLine:)])
    {
        [delegate toggleBreakpointForFile:self.fileName onLine:lineNum];
    }
    
    SMLLineNumbers* lineNumbers = [[MGSFragaria currentInstance] objectForKey:ro_MGSFOLineNumbers];
    
    [lineNumbers updateLineNumbersCheckWidth:NO recolour:NO];
    [self setNeedsDisplay:YES];
}

/*
- (void)drawViewBackgroundInRect:(NSRect)rect
{
    [super drawViewBackgroundInRect:rect];
    
    //NSPoint containerOrigin = [self textContainerOrigin];
    NSLayoutManager* layoutManager = [self layoutManager];
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:8];
    NSLog(@"glyphIndex: %d", (int)glyphIndex);
    
    //[layoutManager ch]
    
    NSPoint glyphLocation = [layoutManager locationForGlyphAtIndex:glyphIndex];
    NSLog(@"glyphLocation: %f,%f", glyphLocation.x, glyphLocation.y);
    
    NSRect bounds = [self bounds];
    
    NSLog(@"bounds: %f,%f,%f,%f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    
    NSLog(@"img0: %@ img1: %@ img2: %@", imgBreakpoint0, imgBreakpoint1, imgBreakpoint2);
    
    //NSDrawThreePartImage(NSMakeRect(2, 110, bounds.size.width-4, 12), imgBreakpoint0, imgBreakpoint1, imgBreakpoint2, NO, NSCompositeSourceOver, 1, NO);
    
    [imgBreakpoint0 drawInRect:NSMakeRect(2, 110, 4, 12) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [imgBreakpoint2 drawInRect:NSMakeRect(bounds.size.width-11, 110, 8, 12) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}*/

/*
 
 - isOpaque
 
 */
- (BOOL)isOpaque
{
	return YES;
}


@end
