//
//  MGSSyntaxErrorController.m
//  Fragaria
//
//  Created by Jim Derry on 2/15/15.
//
//

#import "MGSSyntaxErrorController.h"
#import "SMLLayoutManager.h"
#import "SMLSyntaxError.h"
#import "MGSLineNumberView.h"
#import "SMLTextView.h"
#import "NSTextStorage+Fragaria.h"


#define kSMLErrorPopOverMargin        6.0
#define kSMLErrorPopOverErrorSpacing  2.0

/* Set this to 1 to disable suppression of badge icons in the syntax error
 * balloons when there is only a single error to display. */
#define kSMLAlwaysShowBadgesInBalloon 0



@interface MGSErrorBadgeAttachmentCell : NSTextAttachmentCell

/* This class exists only because NSTextAttachmentCell does not have a setter
 * for cellBaselineOffset. cellBaselineOffset is used to center the badge on
 * the line of the syntax error it is associated with. */

@end

@implementation MGSErrorBadgeAttachmentCell

- (NSPoint)cellBaselineOffset { return NSMakePoint(0,-2); }

@end



@implementation MGSSyntaxErrorController

@synthesize defaultSyntaxErrorHighlightingColour = _defaultSyntaxErrorHighlightingColour;

#pragma mark - Property Accessors


- (void)setSyntaxErrors:(NSArray *)syntaxErrors
{
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[SMLSyntaxError class]];
    }];
    _syntaxErrors = [syntaxErrors filteredArrayUsingPredicate:filter];
    [self updateSyntaxErrorsDisplay];
}


- (void)setShowsSyntaxErrors:(BOOL)showSyntaxErrors
{
    _showsSyntaxErrors = showSyntaxErrors;
    [self updateSyntaxErrorsDisplay];
}

- (void)setShowsIndividualErrors:(BOOL)showsIndividualErrors
{
	_showsIndividualErrors = showsIndividualErrors;
	[self updateSyntaxErrorsDisplay];
}

- (void)setDefaultSyntaxErrorHighlightingColour:(NSColor *)defaultSyntaxErrorHighlightingColour
{
    _defaultSyntaxErrorHighlightingColour = defaultSyntaxErrorHighlightingColour;
    [self updateSyntaxErrorsDisplay];
}

- (NSColor *)defaultSyntaxErrorHighlightingColour
{
    if (!_defaultSyntaxErrorHighlightingColour)
    {
        _defaultSyntaxErrorHighlightingColour = [NSColor colorWithCalibratedRed:1 green:1 blue:0.7 alpha:1];
    }

    return _defaultSyntaxErrorHighlightingColour;
}

- (void)setLineNumberView:(MGSLineNumberView *)lineNumberView
{
    [_lineNumberView setDecorationActionTarget:nil];
    _lineNumberView = lineNumberView;
    [_lineNumberView setDecorationActionTarget:self];
    [_lineNumberView setDecorationActionSelector:@selector(clickedError:)];
    [self updateSyntaxErrorsDisplay];
}


- (void)layoutManagerWillChangeTextStorage
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if (!self.textView)
        return;
    [nc removeObserver:self name:NSTextStorageDidProcessEditingNotification
      object:self.textView.textStorage];
}


- (void)layoutManagerDidChangeTextStorage
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(textStorageDidProcessEditing:)
      name:NSTextStorageDidProcessEditingNotification object:self.textView.textStorage];
    [self updateSyntaxErrorsDisplay];
}


- (void)setTextView:(SMLTextView *)textView
{
    [self layoutManagerWillChangeTextStorage];
    _textView = textView;
    [self layoutManagerDidChangeTextStorage];
}


#pragma mark - Syntax error display


- (void)updateSyntaxErrorsDisplay
{
    if (_textView) [self highlightErrors];
    if (!_showsSyntaxErrors) {
        [self.lineNumberView setDecorations:[NSDictionary dictionary]];
        return;
    }
    [self.lineNumberView setDecorations:[self errorDecorations]];
}


- (void)textStorageDidProcessEditing:(NSNotification*)note
{
    /* Defer to the end of this run loop because when this notification is
     * received, the layout manager is not yet updated with the new contents
     * of the text storage. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self highlightErrors];
    });
}


- (void)highlightErrors
{
    SMLTextView* textView = self.textView;
    NSString* text = [textView string];
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRange wholeRange = NSMakeRange(0, text.length);
    
    // Clear all highlights
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:wholeRange];
    [layoutManager removeTemporaryAttribute:NSToolTipAttributeName forCharacterRange:wholeRange];
    [layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:wholeRange];
    
    if (!self.showsSyntaxErrors) return;
	
    // Highlight all lines with errors
    NSMutableSet* highlightedRows = [NSMutableSet set];
    
    for (SMLSyntaxError* err in self.nonHiddenErrors)
    {
        // Highlight an erroneous line
        NSUInteger zbc = err.character - (err.character != 0);
        NSUInteger zbl = err.line - (err.line != 0);
        NSUInteger location = [layoutManager.textStorage mgs_characterAtIndex:zbc withinRow:zbl];
        
        // Skip lines we cannot identify in the text
        if (location == NSNotFound) continue;
        
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(location, 0)];
        
        // Highlight row if it is not already highlighted
        if (![highlightedRows containsObject:[NSNumber numberWithUnsignedInteger:err.line]])
        {
            // Remember that we are highlighting this row
            [highlightedRows addObject:[NSNumber numberWithUnsignedInteger:err.line]];
            
            // Add highlight for background
            NSColor *highlightColor = err.errorLineHighlightColor ? err.errorLineHighlightColor : self.defaultSyntaxErrorHighlightingColour;
            [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:highlightColor forCharacterRange:lineRange];
        }
        
        NSRange errorRange = NSMakeRange(location, err.length);
        if (!errorRange.length) errorRange = lineRange;
        
        if ([err.errorDescription length] > 0)
            [layoutManager addTemporaryAttribute:NSToolTipAttributeName value:err.errorDescription forCharacterRange:errorRange];
        
        if (self.showsIndividualErrors && err.length) {
            [layoutManager addTemporaryAttribute:NSUnderlineStyleAttributeName value:@(MGSUnderlineStyleSquiggly) forCharacterRange:errorRange];
        }
    }
}


#pragma mark - Instance Methods


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSArray *)linesWithErrors
{
    return [[self.syntaxErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == %@", @(NO)]] valueForKeyPath:@"@distinctUnionOfObjects.line"];
}


- (NSUInteger)errorCountForLine:(NSInteger)line
{
    return [[[self.syntaxErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(line == %@) AND (hidden == %@)", @(line), @(NO)]] valueForKeyPath:@"@count"] integerValue];
}


- (SMLSyntaxError *)errorForLine:(NSInteger)line
{
    float highestErrorLevel = [[[self errorsForLine:line] valueForKeyPath:@"@max.warningLevel"] floatValue];
    NSArray* errors = [[self errorsForLine:line] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"warningLevel = %@", @(highestErrorLevel)]];

    return errors.firstObject;
}


- (NSArray*)errorsForLine:(NSInteger)line
{
    return [self.syntaxErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(line == %@) AND (hidden == %@)", @(line), @(NO)]];
}


- (NSArray *)nonHiddenErrors
{
    return [self.syntaxErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == %@", @(NO)]];
}


- (NSDictionary *)errorDecorations
{
    return [self errorDecorationsHavingSize:NSMakeSize(0.0, 0.0)];
}


- (NSDictionary *)errorDecorationsHavingSize:(NSSize)size
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    for (NSNumber *line in [self linesWithErrors])
    {
        NSImage *image = [[self errorForLine:[line integerValue]] warningImage];
        if (size.height > 0.0 && size.width > 0)
        {
            [image setSize:size];
        }
        [result setObject:image forKey:line];
    }

    return result;
}


#pragma mark - Action methods


- (void)clickedError:(MGSLineNumberView *)sender
{
    NSRect rect;
    NSUInteger selLine;
    
    selLine = [sender selectedLineNumber];
    rect = [sender decorationRectOfLine:selLine];
    [self showErrorsForLine:selLine+1 relativeToRect:rect ofView:sender];
}


- (void)showErrorsForLine:(NSUInteger)line relativeToRect:(NSRect)rect ofView:(NSView*)view
{
    NSArray *errors, *images;
    NSFont* font;
    NSMutableAttributedString *errorsString;
    NSMutableParagraphStyle *parStyle;
    NSTextField *textField;
    NSSize balloonSize;
    NSInteger i, c;
    
    errors = [[self errorsForLine:line] valueForKey:@"errorDescription"];
    images = [[self errorsForLine:line] valueForKey:@"warningImage"];
    if (!(c = [errors count])) return;

    // Create view controller
    NSViewController *vc = [[NSViewController alloc] init];
    [vc setView:[[NSView alloc] init]];

    errorsString = [[NSMutableAttributedString alloc] init];
    i = 0;
    for (NSString* err in errors) {
        NSMutableString *muts;
        NSImage *warnImg;
        NSTextAttachment *attachment;
        MGSErrorBadgeAttachmentCell *attachmentCell;
        NSAttributedString *attachmStr;

        muts = [err mutableCopy];
        [muts replaceOccurrencesOfString:@"\n" withString:@"\u2028" options:0 range:NSMakeRange(0, [muts length])];
        if (i != 0)
            [[errorsString mutableString] appendString:@"\n"];
        
        if (kSMLAlwaysShowBadgesInBalloon || c > 1) {
            warnImg = [[images objectAtIndex:i] copy];
            [warnImg setSize:NSMakeSize(11,11)];
            
            attachment = [[NSTextAttachment alloc] init];
            attachmentCell = [[MGSErrorBadgeAttachmentCell alloc] initImageCell:warnImg];
            [attachment setAttachmentCell:attachmentCell];
            attachmStr = [NSAttributedString attributedStringWithAttachment:attachment];
            [errorsString appendAttributedString:attachmStr];
            [[errorsString mutableString] appendString:@" "];
        }
        
        [[errorsString mutableString] appendString:muts];
        i++;
    }

    font = [NSFont systemFontOfSize:10];
    parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [parStyle setParagraphSpacing:kSMLErrorPopOverErrorSpacing];
    [errorsString addAttributes: @{NSParagraphStyleAttributeName: parStyle,
      NSFontAttributeName: font} range:NSMakeRange(0, [errorsString length])];

    textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [textField setAllowsEditingTextAttributes:YES];
    [textField setAttributedStringValue:errorsString];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField sizeToFit];
    [textField setFrameOrigin:NSMakePoint(kSMLErrorPopOverMargin, kSMLErrorPopOverMargin)];

    [vc.view addSubview:textField];
    balloonSize = [textField frame].size;
    balloonSize.width += 2 * kSMLErrorPopOverMargin;
    balloonSize.height += 2 * kSMLErrorPopOverMargin;
    [vc.view setFrameSize:balloonSize];

    // Open the popover
    NSPopover* popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = vc.view.bounds.size;
    popover.contentViewController = vc;
    popover.animates = YES;

    [popover showRelativeToRect:rect ofView:view preferredEdge:NSMinYEdge];
}


@end



