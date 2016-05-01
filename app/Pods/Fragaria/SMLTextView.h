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

#import <Cocoa/Cocoa.h>
#import "MGSFragariaTextViewDelegate.h"


@class MGSFragariaView;

@protocol MGSDragOperationDelegate;
@protocol SMLAutoCompleteDelegate;


/** The SMLTextView is the text view used by Fragaria. It implements most of
 *  Fragaria's functionality. */

@interface SMLTextView : NSTextView


#pragma mark - Accessing Text Content
/// @name Accessing Text Content


/** The text editor string, including temporary attributes which have been
*  applied by the syntax colourer. */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied;


#pragma mark - Getting Line and Column Information
/// @name Getting Line and Column Information


/** Get the row and the column corresponding to the given character index.
 *  @param r If not NULL, on return points to the row index where i is located,
 *    or to NSNotFound if the character index is invalid.
 *  @param c If not NULL, on return points to the column index where i is
 *    located, or to NSNotFound if the character index is invalid.
 *  @param i The character index.
 *  @discussion If i points to a tabulation character, only the first of the
 *    columns spanned by the tabulation will be returned. If i points to one
 *    past the last character in the string, the row and column returned
 *    will point to where that character will be when it is inserted. */
- (void)getRow:(NSUInteger *)r column:(NSUInteger *)c forCharacterIndex:(NSUInteger)i;

/** Get the row and the offset in that row which correspond to the given
 *  character index.
 *  @param r If not NULL, on return points to the row index where i is located,
 *    or to NSNotFound if the character index is invalid.
 *  @param c If not NULL, on return points to the index in the row r where i is
 *    located, or to NSNotFound if the character index is invalid.
 *  @param i The character index.
 *  @discussion If i points to one past the last character in the string, the
 *    row and index returned will point to where that character will be when
 *    it is inserted. */
- (void)getRow:(NSUInteger *)r indexInRow:(NSUInteger *)c forCharacterIndex:(NSUInteger)i;

/** The character index corresponding to the given column and row.
 *  @param c A column index.
 *  @param r A row index.
 *  @returns A character index, or NSNotFound if there is no character at the
 *    specified position.
 *  @discussion If the column and the row point inside of a tabulation
 *    character, the index of that character is returned. Newline characters
 *    are assumed to span all the columns past the last one in the line's
 *    contents. */
- (NSUInteger)characterIndexAtColumn:(NSUInteger)c withinRow:(NSUInteger)r;

/** The character index corresponding to the offset of a character in its row.
 *  @param c A character index, relative to the beginning of the row.
 *  @param r A row index.
 *  @returns A character index, or NSNotFound if there is no character at the
 *    specified position.
 *  @discussion Any line number returned by mgs_rowOfCharacter: is a valid
 *    line number for this function. If the line number is valid, this function
 *    will always return a valid character index in that line. If the
 *    index parameter specifies a character outside the bounds of the line,
 *    the index of one past the last character of content of that line will be
 *    returned. */
- (NSUInteger)characterIndexAtIndex:(NSUInteger)c withinRow:(NSUInteger)r;


#pragma mark - Configuring Syntax Highlighting
/// @name Configuring Syntax Highlighting


/** Specifies if the syntax colourer has to be disabled or not. */
@property (nonatomic, getter=isSyntaxColoured) BOOL syntaxColoured;


#pragma mark - Configuring Autocompletion
/// @name Configuring Autocompletion


/** The autocomplete delegate for this instance of SMLTextView. The autocomplete
*  delegate provides a list of words that can be used by the autocomplete
*  feature. If this property is nil, then the list of autocomplete words will
*  be read from the current syntax highlighting dictionary. */
@property (weak) id<SMLAutoCompleteDelegate> autoCompleteDelegate;

/** Specifies the delay time for autocomplete, in seconds. */
@property double autoCompleteDelay;
/** Specifies whether or not auto complete is enabled. */
@property BOOL autoCompleteEnabled;
/** If set to YES, the autocomplete list will contain all the keywords of
 *  the current syntax definition, in addition to the list provided by the
 *  autocomplete delegate. */
@property BOOL autoCompleteWithKeywords;


#pragma mark - Highlighting the current line
/// @name Highlighting the Current Line


/** Specifies the color to use when highlighting the current line.*/
@property (nonatomic, strong) NSColor *currentLineHighlightColour;
/** Specifies whether or not the line with the cursor should be highlighted.*/
@property (nonatomic, assign) BOOL highlightsCurrentLine;


#pragma mark - Tabulation and Indentation
/// @name Tabulation and Indentation


/** Indicates the number of spaces per tab character. */
@property (nonatomic, assign) NSInteger tabWidth;
/** Specifies the automatic indentation width. */
@property (nonatomic, assign) NSUInteger indentWidth;
/** Specifies whether spaces should be inserted instead of tab characters when 
 *  indenting. */
@property (nonatomic, assign) BOOL indentWithSpaces;
/** Specifies whether or not tab stops should be used when indenting. */
@property (nonatomic, assign) BOOL useTabStops;
/** Indicates whether or not braces should be indented automatically. */
@property (nonatomic, assign) BOOL indentBracesAutomatically;
/** Indicates whether or not new lines should be indented automatically. */
@property (nonatomic, assign) BOOL indentNewLinesAutomatically;

/** The real location of the specified character index in its line, in
 *  characters.
 *  @discussion This method takes in account the real width of tabulation
 *              characters.
 *  @param c A character index in the text view's string. */
- (NSUInteger)realColumnOfCharacter:(NSUInteger)c;


#pragma mark - Automatic Bracing
/// @name Automatic Bracing


/** Specifies whether or not closing parentheses are inserted automatically. */
@property (nonatomic, assign) BOOL insertClosingParenthesisAutomatically;
/** Specifies whether or not closing braces are inserted automatically. */
@property (nonatomic, assign) BOOL insertClosingBraceAutomatically;

/** Specifies whether or not matching braces are shown in the editor. */
@property (nonatomic, assign) BOOL showsMatchingBraces;


#pragma mark - Page Guide and Line Wrap
/// @name Showing the Page Guide


/** Specifies the column position to draw the page guide. Independently of
 *  whether or not showsPageGuide is enabled, also indicates the line wrap
 *  column when both lineWrap and lineWrapsAtPageGuide are enabled.*/
@property (nonatomic, assign) NSInteger pageGuideColumn;
/** Specifies whether or not to show the page guide. */
@property (nonatomic, assign) BOOL showsPageGuide;

/** Indicates whether or not line wrap (word wrap) is enabled. */
@property (nonatomic, assign) BOOL lineWrap;
/** If lineWrap is enabled, this indicates whether the line should wrap at the 
 *  page guide column. */
@property (nonatomic, assign) BOOL lineWrapsAtPageGuide;


#pragma mark - Showing Invisible Characters
/// @name Showing Invisible Characters


/** Indicates whether or not invisible characters in the editor are revealed.*/
@property (nonatomic, assign) BOOL showsInvisibleCharacters;
/** Specifies the colour to render invisible characters in the text view.*/
@property (nonatomic, assign) NSColor *textInvisibleCharactersColour;


#pragma mark - Configuring Text Appearance
/// @name Configuring Text Appearance


/** Indicates the current text color. */
@property (copy) NSColor *textColor;
/** Indicates the current editor font. */
@property (nonatomic) NSFont *textFont;
/** The natural line height of the receiver is multiplied by this factor to
 *  get the real line height. The default value is 0.0. */
@property (nonatomic) CGFloat lineHeightMultiple;


#pragma mark - Configuring Additional Text View Behavior
/// @name Configuring Additional Text View Behavior


/** The text view's delegate */
@property (assign) id<MGSFragariaTextViewDelegate, MGSDragOperationDelegate> delegate;
/** Indicates the current insertion point color. */
@property (nonatomic, assign) NSColor *insertionPointColor;


@end
