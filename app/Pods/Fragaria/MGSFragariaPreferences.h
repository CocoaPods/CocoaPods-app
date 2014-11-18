/*
 *  MGSFragariaPreferences.h
 *  Fragaria
 *
 *  Created by Jonathan on 06/05/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// Fragraria preference keys by type

// color data
// [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
extern NSString * const MGSFragariaPrefsCommandsColourWell;
extern NSString * const MGSFragariaPrefsCommentsColourWell;
extern NSString * const MGSFragariaPrefsInstructionsColourWell;
extern NSString * const MGSFragariaPrefsKeywordsColourWell;
extern NSString * const MGSFragariaPrefsAutocompleteColourWell;
extern NSString * const MGSFragariaPrefsVariablesColourWell;
extern NSString * const MGSFragariaPrefsStringsColourWell;
extern NSString * const MGSFragariaPrefsAttributesColourWell;
extern NSString * const MGSFragariaPrefsBackgroundColourWell;
extern NSString * const MGSFragariaPrefsTextColourWell;
extern NSString * const MGSFragariaPrefsGutterTextColourWell;
extern NSString * const MGSFragariaPrefsInvisibleCharactersColourWell;
extern NSString * const MGSFragariaPrefsHighlightLineColourWell;
extern NSString * const MGSFragariaPrefsNumbersColourWell;

// bool
extern NSString * const MGSFragariaPrefsColourNumbers;
extern NSString * const MGSFragariaPrefsColourCommands;
extern NSString * const MGSFragariaPrefsColourComments;
extern NSString * const MGSFragariaPrefsColourInstructions;
extern NSString * const MGSFragariaPrefsColourKeywords;
extern NSString * const MGSFragariaPrefsColourAutocomplete;
extern NSString * const MGSFragariaPrefsColourVariables;
extern NSString * const MGSFragariaPrefsColourStrings;	
extern NSString * const MGSFragariaPrefsColourAttributes;	
extern NSString * const MGSFragariaPrefsShowFullPathInWindowTitle;
extern NSString * const MGSFragariaPrefsShowLineNumberGutter;
extern NSString * const MGSFragariaPrefsSyntaxColourNewDocuments;
extern NSString * const MGSFragariaPrefsLineWrapNewDocuments;
extern NSString * const MGSFragariaPrefsIndentNewLinesAutomatically;
extern NSString * const MGSFragariaPrefsOnlyColourTillTheEndOfLine;
extern NSString * const MGSFragariaPrefsShowMatchingBraces;
extern NSString * const MGSFragariaPrefsShowInvisibleCharacters;
extern NSString * const MGSFragariaPrefsIndentWithSpaces;
extern NSString * const MGSFragariaPrefsColourMultiLineStrings;
extern NSString * const MGSFragariaPrefsAutocompleteSuggestAutomatically;
extern NSString * const MGSFragariaPrefsAutocompleteIncludeStandardWords;
extern NSString * const MGSFragariaPrefsAutoSpellCheck;
extern NSString * const MGSFragariaPrefsAutoGrammarCheck;
extern NSString * const MGSFragariaPrefsSmartInsertDelete;
extern NSString * const MGSFragariaPrefsAutomaticLinkDetection;
extern NSString * const MGSFragariaPrefsAutomaticQuoteSubstitution;
extern NSString * const MGSFragariaPrefsUseTabStops;
extern NSString * const MGSFragariaPrefsHighlightCurrentLine;
extern NSString * const MGSFragariaPrefsAutomaticallyIndentBraces;
extern NSString * const MGSFragariaPrefsAutoInsertAClosingParenthesis;
extern NSString * const MGSFragariaPrefsAutoInsertAClosingBrace;
extern NSString * const MGSFragariaPrefsShowPageGuide;

// integer
extern NSString * const MGSFragariaPrefsGutterWidth;
extern NSString * const MGSFragariaPrefsTabWidth;
extern NSString * const MGSFragariaPrefsIndentWidth;
extern NSString * const MGSFragariaPrefsShowPageGuideAtColumn;	
extern NSString * const MGSFragariaPrefsSpacesPerTabEntabDetab;

// float
extern NSString * const MGSFragariaPrefsAutocompleteAfterDelay;	

// font data
// [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
extern NSString * const MGSFragariaPrefsTextFont;

// string
extern NSString * const MGSFragariaPrefsSyntaxColouringPopUpString;

#import "MGSFragariaPrefsViewController.h"
#import "MGSFragariaFontsAndColoursPrefsViewController.h"
#import "MGSFragariaTextEditingPrefsViewController.h"

@interface MGSFragariaPreferences : NSObject {
    
    MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
    MGSFragariaTextEditingPrefsViewController *textEditingPrefsViewController;
}
+ (void)initializeValues;
+ (MGSFragariaPreferences *)sharedInstance;
- (void)changeFont:(id)sender;
- (void)revertToStandardSettings:(id)sender;

@property (readonly) MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
@property (readonly) MGSFragariaTextEditingPrefsViewController *textEditingPrefsViewController;

@end



