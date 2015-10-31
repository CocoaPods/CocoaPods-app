//
//  SMLTextView+MGSTextActions.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 09/02/15.
//
//

#import "SMLTextView.h"


/** 
 *  MGSTextActions implements the text view actions added by Fragaria to
 *  NSTextView. These actions are typically made available to the user through
 *  a "Text" menu. 
 */

@interface SMLTextView (MGSTextActions)


/** Removes trailing whitespace in the currently selected range.
 *  @discussion The selected range is expanded to include an integer number
 *              of lines.
 *  @param sender The sender of the action. */
- (IBAction)removeNeedlessWhitespace:(id)sender;


/** Replaces tabulations with spaces in the selected range.
 *  @discussion This method will open a sheet attached to Fragaria's parent
 *              window to ask the user the width (in spaces) of a tabulation.
 *              Also, the selected range is expanded to include an integer
 *              number of lines. When the user confirms the action, this
 *              method will call -performDetabWithNumberOfSpaces: to actually
 *              perform the operation.
 *  @param sender The sender of the action. */
- (IBAction)detab:(id)sender;

/** Replaces spaces with tabulations in the selected range.
 *  @discussion This method will open a sheet attached to Fragaria's parent
 *              window to ask the user the width (in spaces) of a tabulation.
 *              Also, the selected range is expanded to include an integer
 *              number of lines. When the user confirms the action, this
 *              method will call -performEntabWithNumberOfSpaces: to actually
 *              perform the operation.
 *  @param sender The sender of the action. */
- (IBAction)entab:(id)sender;


/** Replaces spaces with tabulations in the selected range.
 *  @discussion The selected range is expanded to include an integer number
 *              of lines.
 *  @param numberOfSpaces The maximum width of a tabulation, in spaces. */
- (void)performEntabWithNumberOfSpaces:(NSInteger)numberOfSpaces;

/** Replaces tabulations with spaces in the selected range.
 *  @discussion The selected range is expanded to include an integer number
 *              of lines.
 *  @param numberOfSpaces The maximum width of a tabulation, in spaces. */
- (void)performDetabWithNumberOfSpaces:(NSInteger)numberOfSpaces;


/** De-indent the selected range by indentWidth spaces.
 *  @discussion The selected range is expanded to include an integer number
 *              of lines.
 *  @param sender The sender of the action. */
- (IBAction)shiftLeft:(id)sender;

/** Indent the selected range by indentWidth.
 *  @discussion The selected range is expanded to include an integer number
 *              of lines.
 *  @param sender The sender of the action. */
- (IBAction)shiftRight:(id)sender;


/** Change all alfabetic characters in the selection to lower case.
 *  @param sender The sender of the action. */
- (IBAction)lowercaseCharacters:(id)sender;

/** Change all alfabetic characters in the selection to upper case.
 *  @param sender The sender of the action. */
- (IBAction)uppercaseCharacters:(id)sender;

/** Capitalize the words in the selection.
 *  @param sender The sender of the action. */
- (IBAction)capitalizeWord:(id)sender;


/** Present an interface to allow the user to scroll the view to a text line.
 *  @discussion This method will open a sheet attached to Fragaria's parent
 *              window to ask the user the line to be scrolled into view.
 *              When the user confirms the action, this method will call 
 *              -performGoToLine:setSelected: to actually perform the operation.
 *  @param sender The sender of the action. */
- (IBAction)goToLine:(id)sender;

/** Scroll the view to the specified line number.
 *  @param lineToGoTo The one-based line number to go to.
 *  @param highlight Indicates whether the line should be selected. */
- (void)performGoToLine:(NSInteger)lineToGoTo setSelected:(BOOL)highlight;


/** Close the last XHTML or HTML tag still opened.
 *  @discussion This method special-cases various XHTML and HTML tags to ensure
 *              it does not close self-closing tags, such as \<br\>, \<image\>
 *              and \<!-- --\>.
 *  @param sender The sender of the action. */
- (IBAction)closeTag:(id)sender;


/** Toggle commenting of the selected range.
 *  @discussion This method looks only for single-line comments starting at the
 *              beginning of each line. This method either comments or
 *              uncomments each selected range separately, aligned to line
 *              bonduaries. Uncommenting is performed only if all selected lines
 *              are commented; otherwise, they are commented.
 *  @param sender The sender of the action. */
- (IBAction)commentOrUncomment:(id)sender;


/** Remove line breaks from the selected range.
 *  @discussion All unicode line breaks are supported.
 *  @param sender The sender of the action. */
- (IBAction)removeLineEndings:(id)sender;


/** Substitute XML escapes in the selected text.
 *  @discussion The XML escapes supported by this method are \&amp;, \&lt; and
 *              \&gt;.
 *  @param sender The sender of the action. */
- (IBAction)prepareForXML:(id)sender;


/** Transpose the two characters on the sides of the current insertion point.
 *  @param sender The sender of the action. */
- (IBAction)transpose:(id)sender;


@end
