//
//  MGSFragariaView+Definitions.h
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import <Cocoa/Cocoa.h>
#import "MGSFragariaView.h"


/**
 *  # Fragaria Property User Defaults Keys
 *
 *  ## Use with MGSUserDefaultsController and MGSUserDefaults:
 *  These keys can be used in your code to manage Fragaria properties and
 *  user defaults for any instance of MGSFragariaView. The keys' names
 *  correspond fairly well with MGSFragariaView's properties properties.
 *
 *  ## For use in KVO/KVC/IB:
 *  The string values can be found in MGSUserDefaults.m and are also documented
 *  in the comments after each declaration below. For convenience the string
 *  value is identical to the MGSFragariaView property name. These definitions
 *  are also critical to how MGSUserDefaultsController operates, so do not
 *  change them for namespacing purposes (see +namespacedKeyForKey).
 *
 *  ## For use when managing defaults and properties yourself:
 *  For convenience and type safety some convenience methods are provided in
 *  this class in order to use the constants as much as possible.
 */

// Configuring Syntax Highlighting
extern NSString * const MGSFragariaDefaultsSyntaxColoured;                        // BOOL       syntaxColoured
extern NSString * const MGSFragariaDefaultsSyntaxDefinitionName;                  // NSString   syntaxDefinitionName
extern NSString * const MGSFragariaDefaultsColoursMultiLineStrings;               // BOOL       coloursMultiLineStrings
extern NSString * const MGSFragariaDefaultsColoursOnlyUntilEndOfLine;             // BOOL       coloursOnlyUntilEndOfLine

// Configuring Autocompletion
extern NSString * const MGSFragariaDefaultsAutoCompleteDelay;                     // double     autoCompleteDelay
extern NSString * const MGSFragariaDefaultsAutoCompleteEnabled;                   // BOOL       autoCompleteEnabled
extern NSString * const MGSFragariaDefaultsAutoCompleteWithKeywords;              // BOOL       autoCompleteWithKeywords

// Highlighting the current line
extern NSString * const MGSFragariaDefaultsCurrentLineHighlightColour;            // NSColor    currentLineHighlightColour
extern NSString * const MGSFragariaDefaultsHighlightsCurrentLine;                 // BOOL       highlightsCurrentLine

// Configuring the Gutter
extern NSString * const MGSFragariaDefaultsShowsGutter;                           // BOOL       showsGutter
extern NSString * const MGSFragariaDefaultsMinimumGutterWidth;                    // CGFloat    minimumGutterWidth
extern NSString * const MGSFragariaDefaultsShowsLineNumbers;                      // BOOL       showsLineNumbers
extern NSString * const MGSFragariaDefaultsStartingLineNumber;                    // NSUInteger startingLineNumber
extern NSString * const MGSFragariaDefaultsGutterFont;                            // NSFont     gutterFont
extern NSString * const MGSFragariaDefaultsGutterTextColour;                      // NSColor    gutterTextColour

// Showing Syntax Errors
extern NSString * const MGSFragariaDefaultsShowsSyntaxErrors;                     // BOOL       showsSyntaxErrors
extern NSString * const MGSFragariaDefaultsShowsIndividualErrors;                 // BOOL       showsIndividualErrors
extern NSString * const MGSFragariaDefaultsDefaultErrorHighlightingColor;         // NSColor    defaultSyntaxErrorHighlightingColour

// Tabulation and Indentation
extern NSString * const MGSFragariaDefaultsTabWidth;                              // NSInteger  tabWidth
extern NSString * const MGSFragariaDefaultsIndentWidth;                           // NSUInteger indentWidth
extern NSString * const MGSFragariaDefaultsUseTabStops;                           // BOOL       useTabStops
extern NSString * const MGSFragariaDefaultsIndentWithSpaces;                      // BOOL       indentWithSpaces
extern NSString * const MGSFragariaDefaultsIndentBracesAutomatically;             // BOOL       indentBracesAutomatically
extern NSString * const MGSFragariaDefaultsIndentNewLinesAutomatically;           // BOOL       indentNewLinesAutomatically

// Automatic Bracing
extern NSString * const MGSFragariaDefaultsInsertClosingBraceAutomatically;       // BOOL   insertClosingBraceAutomatically
extern NSString * const MGSFragariaDefaultsInsertClosingParenthesisAutomatically; // BOOL   insertClosingParenthesisAutomatically
extern NSString * const MGSFragariaDefaultsShowsMatchingBraces;                   // BOOL   showsMatchingBraces

// Page Guide and Line Wrap
extern NSString * const MGSFragariaDefaultsPageGuideColumn;                       // NSInteger  pageGuideColumn
extern NSString * const MGSFragariaDefaultsShowsPageGuide;                        // BOOL       showsPageGuide
extern NSString * const MGSFragariaDefaultsLineWrap;                              // BOOL       lineWrap
extern NSString * const MGSFragariaDefaultsLineWrapsAtPageGuide;                  // BOOL       lineWrapsAtPageGuide

// Showing Invisible Characters
extern NSString * const MGSFragariaDefaultsShowsInvisibleCharacters;              // BOOL    showsInvisibleCharacters
extern NSString * const MGSFragariaDefaultsTextInvisibleCharactersColour;         // NSColor textInvisibleCharactersColour

// Configuring Text Appearance
extern NSString * const MGSFragariaDefaultsTextColor;                             // NSColor textColor
extern NSString * const MGSFragariaDefaultsBackgroundColor;                       // NSColor backgroundColor
extern NSString * const MGSFragariaDefaultsTextFont;                              // NSFont  textFont

// Configuring Additional Text View Behavior
extern NSString * const MGSFragariaDefaultsHasVerticalScroller;                   // BOOL    hasVerticalScroller
extern NSString * const MGSFragariaDefaultsInsertionPointColor;                   // NSColor insertionPointColor
extern NSString * const MGSFragariaDefaultsScrollElasticityDisabled;              // BOOL    scrollElasticityDisabled

// Syntax Highlighting Colours
extern NSString * const MGSFragariaDefaultsColourForAutocomplete;                 // NSColor colourForAutocomplete
extern NSString * const MGSFragariaDefaultsColourForAttributes;                   // NSColor colourForAttributes
extern NSString * const MGSFragariaDefaultsColourForCommands;                     // NSColor colourForCommands
extern NSString * const MGSFragariaDefaultsColourForComments;                     // NSColor colourForComments
extern NSString * const MGSFragariaDefaultsColourForInstructions;                 // NSColor colourForInstructions
extern NSString * const MGSFragariaDefaultsColourForKeywords;                     // NSColor colourForKeywords
extern NSString * const MGSFragariaDefaultsColourForNumbers;                      // NSColor colourForNumbers
extern NSString * const MGSFragariaDefaultsColourForStrings;                      // NSColor colourForStrings
extern NSString * const MGSFragariaDefaultsColourForVariables;                    // NSColor colourForVariables

// Syntax Highlighter Colouring Options
extern NSString * const MGSFragariaDefaultsColoursAttributes;                     // BOOL coloursAttributes
extern NSString * const MGSFragariaDefaultsColoursAutocomplete;                   // BOOL coloursAutocomplete
extern NSString * const MGSFragariaDefaultsColoursCommands;                       // BOOL coloursCommands
extern NSString * const MGSFragariaDefaultsColoursComments;                       // BOOL coloursComments
extern NSString * const MGSFragariaDefaultsColoursInstructions;                   // BOOL coloursInstructions
extern NSString * const MGSFragariaDefaultsColoursKeywords;                       // BOOL coloursKeywords
extern NSString * const MGSFragariaDefaultsColoursNumbers;                        // BOOL coloursNumbers
extern NSString * const MGSFragariaDefaultsColoursStrings;                        // BOOL coloursStrings
extern NSString * const MGSFragariaDefaultsColoursVariables;                      // BOOL coloursVariables


/**
 *  This category consists of several methods that serve as conveniences for
 *  working with the defaults coordinator and MGSFragariaView. It might be
 *  useful for other purposes too.
 */

@interface MGSFragariaView (MGSUserDefaultsDefinitions)


#pragma mark - Setting and getting default values
/// @name Setting and getting default values


/** An NSDictionary of default values for MGSFragariaView's properties.
 *  @discussion The key names are standard KVO key names of MGSFragariaView's
 *      properties, thus they are not prefixed. The key names can also be
 *      accessed by using the Fragaria Property User Defaults Keys. */
+ (NSDictionary *)defaultsDictionary;

/** An NSDictionary of default values for MGSFragariaView's properties.
 *  @discussion The key names are namespaced with -namespacedKeyForKey:. They
 *      can't be accessed directly using the Fragaria Property User Defaults
 *      Keys unless you namespace them with -namespacedKeyForKey: before.
 *
 *      This method is intended to be used with NSUserDefaults, to register
 *      initial defaults. If you are using MGSUserDefaultsController, you don't
 *      need to do this automatically though. */
+ (NSDictionary *)defaultsDictionaryWithNamespace;


/** Reset the properties of Fragaria to the defaults.
 *  @discussion The defaults used are the ones returned by 
 *      -defaultsDictionary. */
- (void)resetDefaults;


#pragma mark - Getting defaults keys
/// @name Getting defaults keys


/** Returns a namespaced defaults key for the specified KVO key of Fragaria.
 *  @discussion This method adds a prefix to the given string to avoid
 *      clashing with other defaults keys.
 *  @param aString The key to namespace. */
+ (NSString *)namespacedKeyForKey:(NSString *)aString;


/** A convenience NSSet of all of the editing group property strings. */
+ (NSSet *)propertyGroupEditing;
/** A convenience NSSet of all of the gutter group property strings. */
+ (NSSet *)propertyGroupGutter;
/** A convenience NSSet of all of the autocomplete group property strings. */
+ (NSSet *)propertyGroupAutocomplete;
/** A convenience NSSet of all of the indenting group property strings. */
+ (NSSet *)propertyGroupIndenting;

/** A convenience NSSet of all of the text font group property strings. */
+ (NSSet *)propertyGroupTextFont;
/** A convenience NSSet of all of the editor colours group property strings. */
+ (NSSet *)propertyGroupEditorColours;
/** A convenience NSSet of all of the syntax colours group property strings. */
+ (NSSet *)propertyGroupSyntaxHighlightingColours;
/** A convenience NSSet of all of the syntax colours bools group property strings. */
+ (NSSet *)propertyGroupSyntaxHighlightingBools;
/** A convenience NSSet of all of the syntax colours group property strings. */
+ (NSSet *)propertyGroupSyntaxHighlighting;

/** A convenience NSSet of all of the colours property strings. */
+ (NSSet *)propertyGroupTheme;
/** A convenience NSSet of all of the syntax colours extra option group
 *  property strings. */
+ (NSSet *)propertyGroupColouringExtraOptions;


@end
