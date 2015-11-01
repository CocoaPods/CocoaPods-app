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
