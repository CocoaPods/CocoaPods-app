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

#import <Cocoa/Cocoa.h>
#import "MGSFragaria.h"
#import "SMLTextView.h"
#import "SMLAutoCompleteDelegate.h"

@class SMLLayoutManager;
@class ICUPattern;
@class ICUMatcher;

@interface SMLSyntaxColouring : NSObject <NSTextStorageDelegate, NSTextViewDelegate, MGSFragariaTextViewDelegate, SMLAutoCompleteDelegate> {
	
	id document;
	
	SMLLayoutManager *firstLayoutManager;
	
	NSInteger lastCursorLocation;
	
	NSDictionary *commandsColour, *commentsColour, *instructionsColour, *keywordsColour, *autocompleteWordsColour,
					*stringsColour, *variablesColour, *attributesColour, *lineHighlightColour,  *numbersColour;
	
	NSSet *keywords;
	NSSet *autocompleteWords;
	NSArray *keywordsAndAutocompleteWords;

	NSString *beginCommand;
	NSString *endCommand;
	NSString *beginInstruction;
	NSString *endInstruction;
	NSString *firstString;
	NSString *secondString;
	NSString *firstSingleLineComment, *secondSingleLineComment;
    NSString *beginFirstMultiLineComment, *endFirstMultiLineComment, *beginSecondMultiLineComment, *endSecondMultiLineComment;
    NSString *functionDefinition, *removeFromFunction;

    NSMutableArray *singleLineComments;
    NSMutableArray *multiLineComments;
    
	unichar firstStringUnichar;
	unichar secondStringUnichar;

	BOOL reactToChanges;
	BOOL keywordsCaseSensitive;
	BOOL recolourKeywordIfAlreadyColoured;
	BOOL syntaxErrorsAreDirty;
	BOOL syntaxDefinitionAllowsColouring;
    
	NSCharacterSet *attributesCharacterSet;
	NSCharacterSet *beginVariableCharacterSet;
	NSCharacterSet *endVariableCharacterSet;
	NSCharacterSet *letterCharacterSet, *keywordStartCharacterSet, *keywordEndCharacterSet;
	NSCharacterSet *numberCharacterSet;
    NSCharacterSet *nameCharacterSet;
    unichar decimalPointCharacter;
    NSArray *syntaxErrors;
    
	ICUPattern *firstStringPattern;
	ICUPattern *secondStringPattern;	
	ICUMatcher *firstStringMatcher;
	ICUMatcher *secondStringMatcher;
	NSUndoManager *undoManager;
    
	NSTimer *autocompleteWordsTimer;

	NSRange lastLineHighlightRange;
    id docSpec;
    
}

@property BOOL reactToChanges;
@property (strong) NSUndoManager *undoManager;
@property (nonatomic, strong) NSArray* syntaxErrors;

- (id)initWithDocument:(id)document;
- (void)pageRecolourTextView:(SMLTextView *)textView;
- (void)pageRecolour;
- (void)applySyntaxDefinition;
- (void)pageRecolourTextView:(SMLTextView *)textView options:(NSDictionary *)options;

@end
