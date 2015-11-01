//
//  MGSSyntaxErrorController.h
//  Fragaria
//
//  Created by Jim Derry on 2/15/15.
//
//

#import <Cocoa/Cocoa.h>


@class SMLTextView;
@class MGSLineNumberView;
@class SMLSyntaxError;


/**
 *  MGSSyntaxErrorController provides internal services and methods to Fragaria
 *  for managing syntax errors.
 **/

@interface MGSSyntaxErrorController : NSObject


/// @name Properties


/** The array of MGSSyntaxError objects which determines the syntax errors
 * shown in the line number view and the text view. */
@property (nonatomic, strong) NSArray *syntaxErrors;

/** Set to YES when syntax errors should be visible both in the line number
 * view and the text view, set to NO to make all syntax errors invisible. */
@property (nonatomic) BOOL showsSyntaxErrors;

/** If showing syntax errors, highlights individual errors instead of
 * highlighting the full line. */
@property (nonatomic, assign) BOOL showsIndividualErrors;

/** The default syntax error line highlighting colour. */
@property (nonatomic, strong) NSColor *defaultSyntaxErrorHighlightingColour;

/** The MGSLineNumberView where to show the error decorations (icons) */
@property (nonatomic) MGSLineNumberView *lineNumberView;

/** The SMLTextView where to highlight the lines where the errors are. */
@property (nonatomic) SMLTextView *textView;


/// @name Instance Methods


/**
 *  Returns an array of NSNumber indicating unique line numbers that are assigned errors.
 *  Syntax errors that have hidden == true will not be counted.
 **/
- (NSArray *)linesWithErrors;

/**
 *  Returns the number of errors assigned to line `line`.
 *  Syntax errors that have hidden == true will not be counted.
 *  @param line is the line number to check.
 **/
- (NSUInteger)errorCountForLine:(NSInteger)line;

/**
 *  Returns the first error with the highest warningLevel for line `line`.
 *  Syntax errors that have hidden == true will not be counted.
 *  @param line is the line number to check.
 **/
- (SMLSyntaxError *)errorForLine:(NSInteger)line;

/**
 *  Returns an array of all of the errors assigned to line `line`.
 *  Syntax errors that have hidden == true will not be counted.
 *  @param line is the line number to check.
 **/
- (NSArray*)errorsForLine:(NSInteger)line;

/**
 *  Returns an array of all of the non-hidden errors in `errorArray`.
 *  Syntax errors that have hidden == true will not be returned.
 **/
- (NSArray *)nonHiddenErrors;

/**
 *  Returns an NSDictionary of key-value pairs indicating decorations
 *  suitable for each line.
 *  Syntax errors that have hidden == true will not be counted.
 *  @discussion each key represents a unique line number as NSNUmber,
 *  and its value is an NSImage representing the first error with the
 *  highest warningLevel for that line.
 **/
- (NSDictionary *)errorDecorations;

/**
 *  Returns an NSDictionary of key-value pairs indicating decorations
 *  suitable for each line.
 *  Syntax errors that have hidden == true will not be counted.
 *  @discussion each key represents a unique line number as NSNUmber,
 *  and its value is an NSImage representing the first error with the
 *  highest warningLevel for that line, sized per `size`.
 *  @param size indicates the size of the image in the dictionary.
 **/
- (NSDictionary *)errorDecorationsHavingSize:(NSSize)size;

/**
 *  Displays an NSPopover indicating the error(s).
 *  @param line indicates the line number from which errors should be shown.
 *  @param rect indicates the relative location to display the popover.
 *  @param view indicates the view that the popover is relative to.
 **/
- (void)showErrorsForLine:(NSUInteger)line relativeToRect:(NSRect)rect ofView:(NSView*)view;


/** Inform this syntax error controller that its text view's text storage
 *  will change.
 *  @discussion In response to this message, the syntax error controller must
 *              remove itself as observer of any notifications from the old
 *              text storage. */
- (void)layoutManagerWillChangeTextStorage;

/** Inform this syntax error controller that its text view's text storage
 *  has changed.
 *  @discussion In this method the syntax error controller can register as
 *              observer of any of the new text storage's notifications. */
- (void)layoutManagerDidChangeTextStorage;


@end
