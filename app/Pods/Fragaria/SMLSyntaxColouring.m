// SMLTextView delegate

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

// syntax colouring information dictionary keys
NSString *SMLSyntaxGroup = @"group";
NSString *SMLSyntaxGroupID = @"groupID";
NSString *SMLSyntaxWillColour = @"willColour";
NSString *SMLSyntaxAttributes = @"attributes";
NSString *SMLSyntaxInfo = @"syntaxInfo";

// syntax colouring group names
NSString *SMLSyntaxGroupNumber = @"number";
NSString *SMLSyntaxGroupCommand = @"command";
NSString *SMLSyntaxGroupInstruction = @"instruction";
NSString *SMLSyntaxGroupKeyword = @"keyword";
NSString *SMLSyntaxGroupAutoComplete = @"autocomplete";
NSString *SMLSyntaxGroupVariable = @"variable";
NSString *SMLSyntaxGroupFirstString = @"firstString";
NSString *SMLSyntaxGroupSecondString = @"secondString";
NSString *SMLSyntaxGroupAttribute = @"attribute";
NSString *SMLSyntaxGroupSingleLineComment = @"singleLineComment";
NSString *SMLSyntaxGroupMultiLineComment = @"multiLineComment";
NSString *SMLSyntaxGroupSecondStringPass2 = @"secondStringPass2";

// syntax definition dictionary keys

NSString *SMLSyntaxDefinitionAllowSyntaxColouring = @"allowSyntaxColouring";
NSString *SMLSyntaxDefinitionKeywords = @"keywords";
NSString *SMLSyntaxDefinitionAutocompleteWords = @"autocompleteWords";
NSString *SMLSyntaxDefinitionRecolourKeywordIfAlreadyColoured = @"recolourKeywordIfAlreadyColoured";
NSString *SMLSyntaxDefinitionKeywordsCaseSensitive = @"keywordsCaseSensitive";
NSString *SMLSyntaxDefinitionBeginCommand = @"beginCommand";
NSString *SMLSyntaxDefinitionEndCommand = @"endCommand";
NSString *SMLSyntaxDefinitionBeginInstruction = @"beginInstruction";
NSString *SMLSyntaxDefinitionEndInstruction = @"endInstruction";
NSString *SMLSyntaxDefinitionBeginVariable = @"beginVariable";
NSString *SMLSyntaxDefinitionEndVariable = @"endVariable";
NSString *SMLSyntaxDefinitionFirstString = @"firstString";
NSString *SMLSyntaxDefinitionSecondString = @"secondString";
NSString *SMLSyntaxDefinitionFirstSingleLineComment = @"firstSingleLineComment";
NSString *SMLSyntaxDefinitionSecondSingleLineComment = @"secondSingleLineComment";
NSString *SMLSyntaxDefinitionBeginFirstMultiLineComment = @"beginFirstMultiLineComment";
NSString *SMLSyntaxDefinitionEndFirstMultiLineComment = @"endFirstMultiLineComment";
NSString *SMLSyntaxDefinitionBeginSecondMultiLineComment = @"beginSecondMultiLineComment";
NSString *SMLSyntaxDefinitionEndSecondMultiLineComment = @"endSecondMultiLineComment";
NSString *SMLSyntaxDefinitionFunctionDefinition = @"functionDefinition";
NSString *SMLSyntaxDefinitionRemoveFromFunction = @"removeFromFunction";
NSString *SMLSyntaxDefinitionExcludeFromKeywordStartCharacterSet = @"excludeFromKeywordStartCharacterSet";
NSString *SMLSyntaxDefinitionExcludeFromKeywordEndCharacterSet = @"excludeFromKeywordEndCharacterSet";
NSString *SMLSyntaxDefinitionIncludeInKeywordStartCharacterSet = @"includeInKeywordStartCharacterSet";
NSString *SMLSyntaxDefinitionIncludeInKeywordEndCharacterSet = @"includeInKeywordEndCharacterSet";

// class extension
@interface SMLSyntaxColouring()

@property (copy) NSString *functionDefinition;
@property (copy) NSString *removeFromFunction;
@property (strong) NSString *secondString;
@property (strong) NSString *firstString;
@property (strong) NSString *beginCommand;
@property (strong) NSString *endCommand;
@property (strong) NSSet *keywords;
@property (strong) NSSet *autocompleteWords;
@property (strong) NSArray *keywordsAndAutocompleteWords;
@property (strong) NSString *beginInstruction;
@property (strong) NSString *endInstruction;
@property (strong) NSCharacterSet *beginVariableCharacterSet;
@property (strong) NSCharacterSet *endVariableCharacterSet;
@property (strong) NSString *firstSingleLineComment;
@property (strong) NSString *secondSingleLineComment;
@property (strong) NSMutableArray *singleLineComments;
@property (strong) NSMutableArray *multiLineComments;
@property (strong) NSString *beginFirstMultiLineComment;
@property (strong) NSString*endFirstMultiLineComment;
@property (strong) NSString*beginSecondMultiLineComment;
@property (strong) NSString*endSecondMultiLineComment;
@property (strong) NSCharacterSet *keywordStartCharacterSet;
@property (strong) NSCharacterSet *keywordEndCharacterSet;
@property (strong) NSCharacterSet *attributesCharacterSet;
@property (strong) NSCharacterSet *letterCharacterSet;
@property (strong) NSCharacterSet *numberCharacterSet;
@property (strong) NSCharacterSet *nameCharacterSet;
@property (assign) BOOL syntaxDefinitionAllowsColouring;

@property unichar decimalPointCharacter;

- (void)parseSyntaxDictionary:(NSDictionary *)syntaxDictionary;
- (void)applySyntaxDefinition;
- (NSString *)assignSyntaxDefinition;
- (void)performDocumentDelegateSelector:(SEL)selector withObject:(id)object;
- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer;
- (NSString *)completeString;
- (void)prepareRegularExpressions;
- (void)applyColourDefaults;
- (void)recolourRange:(NSRange)range;
- (void)removeAllColours;
- (void)removeColoursFromRange:(NSRange)range;
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine;
- (void)pageRecolour;
- (void)setColour:(NSDictionary *)colour range:(NSRange)range;
- (void)highlightLineRange:(NSRange)lineRange;
- (void)undoManagerDidUndo:(NSNotification *)aNote;
- (BOOL)isSyntaxColouringRequired;
- (NSDictionary *)syntaxDictionary;
@end

@implementation SMLSyntaxColouring

@synthesize reactToChanges, functionDefinition, removeFromFunction, undoManager, secondString, firstString, keywords, autocompleteWords, keywordsAndAutocompleteWords, beginCommand, endCommand, beginInstruction, endInstruction, beginVariableCharacterSet, endVariableCharacterSet, firstSingleLineComment, secondSingleLineComment, singleLineComments, multiLineComments, beginFirstMultiLineComment, endFirstMultiLineComment, beginSecondMultiLineComment, endSecondMultiLineComment, keywordStartCharacterSet, keywordEndCharacterSet, attributesCharacterSet, letterCharacterSet, numberCharacterSet, decimalPointCharacter, syntaxErrors, syntaxDefinitionAllowsColouring, nameCharacterSet;

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

/*
 
 - initWithDocument:
 
 */
- (id)initWithDocument:(id)theDocument
{
	if ((self = [super init])) {

		NSAssert(theDocument, @"bad document");
		
		// retain the document
		document = theDocument;
		
		self.undoManager = [[NSUndoManager alloc] init];

		// configure the document text view
		NSTextView *textView = [document valueForKey:ro_MGSFOTextView];
		NSAssert([textView isKindOfClass:[NSTextView class]], @"bad textview");
		[textView setDelegate:self];
		[[textView textStorage] setDelegate:self];

		// configure ivars
		lastCursorLocation = 0;
		lastLineHighlightRange = NSMakeRange(0, 0);
		reactToChanges = YES;
		
		// configure layout managers
		firstLayoutManager = (SMLLayoutManager *)[textView layoutManager];
		
		// configure colouring
		[self applyColourDefaults];

		// letter character set
		self.letterCharacterSet = [NSCharacterSet letterCharacterSet];

        // name character set
		NSMutableCharacterSet *temporaryCharacterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
		[temporaryCharacterSet addCharactersInString:@"_"];
		self.nameCharacterSet = [temporaryCharacterSet copy];

		// keyword start character set
		temporaryCharacterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
		[temporaryCharacterSet addCharactersInString:@"_:@#"];
		self.keywordStartCharacterSet = [temporaryCharacterSet copy];
		
		// keyword end character set
        // see http://www.fileformat.info/info/unicode/category/index.htm for categories that make up the sets
		temporaryCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
		[temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
		[temporaryCharacterSet removeCharactersInString:@"_-"]; // common separators in variable names
		self.keywordEndCharacterSet = [temporaryCharacterSet copy];
		
        // number character set
        self.numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        self.decimalPointCharacter = [@"." characterAtIndex:0];
        
		// attributes character set
		temporaryCharacterSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
		[temporaryCharacterSet addCharactersInString:@" -"]; // If there are two spaces before an attribute
		self.attributesCharacterSet = [temporaryCharacterSet copy];
		
		// configure syntax definition
		[self applySyntaxDefinition];
		
		// add undo notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(undoManagerDidUndo:) 
													 name:@"NSUndoManagerDidUndoChangeNotification" 
												   object:undoManager];
		
		// add document KVO observers
		[document addObserver:self forKeyPath:@"syntaxDefinition" options:NSKeyValueObservingOptionNew context:@"syntaxDefinition"];
		
		// add NSUserDefaultsController KVO observers
		NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

		[defaultsController addObserver:self forKeyPath:@"values.FragariaCommandsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaCommentsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaInstructionsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaKeywordsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaAutocompleteColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaVariablesColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaStringsColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaAttributesColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaNumbersColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
        
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourCommands" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourComments" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourInstructions" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourKeywords" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourAutocomplete" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourVariables" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourStrings" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourAttributes" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourNumbers" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
        
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourMultiLineStrings" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaOnlyColourTillTheEndOfLine" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaHighlightCurrentLine" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaHighlightLineColourWell" options:NSKeyValueObservingOptionNew context:@"ColoursChanged"];
		[defaultsController addObserver:self forKeyPath:@"values.FragariaColourMultiLineStrings" options:NSKeyValueObservingOptionNew context:@"MultiLineChanged"];
	}
	
    return self;
}

/*
 
 - dealloc
 
 */
#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(__bridge NSString *)context isEqualToString:@"ColoursChanged"]) {
		[self applyColourDefaults];
		[self pageRecolour];
		if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
			NSRange range = [[self completeString] lineRangeForRange:[[document valueForKey:ro_MGSFOTextView] selectedRange]];
			[self highlightLineRange:range];
			lastLineHighlightRange = range;
		} else {
			[self highlightLineRange:NSMakeRange(0, 0)];
		}
	} else if ([(__bridge NSString *)context isEqualToString:@"MultiLineChanged"]) {
		[self prepareRegularExpressions];
		[self pageRecolour];
	} else if ([(__bridge NSString *)context isEqualToString:@"syntaxDefinition"]) {
		[self applySyntaxDefinition];
		[self removeAllColours];
		[self pageRecolour];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
}


-(void)dealloc
{
    [document removeObserver:self forKeyPath:@"syntaxDefinition"];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}


#pragma mark -
#pragma mark Syntax definition handling
/*
 
 - applySyntaxDefinition
 
 */
- (void)applySyntaxDefinition
{			
	// parse
	[self parseSyntaxDictionary:self.syntaxDictionary];
}

/*
 
 - syntaxDictionary
 
 */
- (NSDictionary *)syntaxDictionary
{
	NSString *definitionName = [document valueForKey:MGSFOSyntaxDefinitionName];
	
	// if document has no syntax definition name then assign one
	if (!definitionName || [definitionName length] == 0) {
		definitionName = [self assignSyntaxDefinition];
	}
	
	// get syntax dictionary
	NSDictionary *syntaxDictionary = [[MGSSyntaxController sharedInstance] syntaxDictionaryWithName:definitionName];
    
    return syntaxDictionary;
}

/*
 
 - assignSyntaxDefinition
 
 */
- (NSString *)assignSyntaxDefinition
{
	NSString *definitionName = [document valueForKey:MGSFOSyntaxDefinitionName];
	if (definitionName && [definitionName length] > 0) return definitionName;

	NSString *documentExtension = [[document valueForKey:MGSFODocumentName] pathExtension];
	
    NSString *lowercaseExtension = nil;
    
    // If there is no extension try to guess definition from first line
    if ([documentExtension isEqualToString:@""]) { 
        
        NSString *string = [[[document valueForKey:ro_MGSFOScrollView] documentView] string];
        NSString *firstLine = [string substringWithRange:[string lineRangeForRange:NSMakeRange(0,0)]];
        if ([firstLine hasPrefix:@"#!"] || [firstLine hasPrefix:@"%"] || [firstLine hasPrefix:@"<?"]) {
            lowercaseExtension = [self guessSyntaxDefinitionExtensionFromFirstLine:firstLine];
        } 
    } else {
        lowercaseExtension = [documentExtension lowercaseString];
    }
    
    if (lowercaseExtension) {
        definitionName = [[MGSSyntaxController sharedInstance] syntaxDefinitionNameWithExtension:lowercaseExtension];
    }
	
	if (!definitionName || [definitionName length] == 0) {
		definitionName = [MGSSyntaxController standardSyntaxDefinitionName];
	}
	
	// update document definition
	[document setValue:definitionName forKey:MGSFOSyntaxDefinitionName];
	
	return definitionName;
}

/*
 
 - parseSyntaxDictionary
 
 */
- (void)parseSyntaxDictionary:(NSDictionary *)syntaxDictionary
{
	
	NSMutableArray *keywordsAndAutocompleteWordsTemporary = [NSMutableArray array];
	
	// If the plist file is malformed be sure to set the values to something
    
    // syntax colouring
    id value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionAllowSyntaxColouring];
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
        self.syntaxDefinitionAllowsColouring = [value boolValue];
    } else {
        // default to YES
        self.syntaxDefinitionAllowsColouring = YES;
    }
    
    // keywords
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionKeywords];
	if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"NSArray expected");
		self.keywords = [[NSSet alloc] initWithArray:value];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:value];
	}
	
    // autocomplete words
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionAutocompleteWords];
	if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"NSArray expected");
		self.autocompleteWords = [[NSSet alloc] initWithArray:value];
		[keywordsAndAutocompleteWordsTemporary addObjectsFromArray:value];
	}
	
    // colour autocomplete words is a preference
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsColourAutocomplete] boolValue] == YES) {
		self.keywords = [NSSet setWithArray:keywordsAndAutocompleteWordsTemporary];
	}
	
    // keywords and autocomplete words
	self.keywordsAndAutocompleteWords = [keywordsAndAutocompleteWordsTemporary sortedArrayUsingSelector:@selector(compare:)];
	
    // recolour keywords
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionRecolourKeywordIfAlreadyColoured];
	if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
		recolourKeywordIfAlreadyColoured = [value boolValue];
	}
	
    // keywords case sensitive
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionKeywordsCaseSensitive];
	if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
		keywordsCaseSensitive = [value boolValue];
	}
	
	if (keywordsCaseSensitive == NO) {
		NSMutableArray *lowerCaseKeywords = [[NSMutableArray alloc] init];
		for (id item in keywords) {
			[lowerCaseKeywords addObject:[item lowercaseString]];
		}
		
		NSSet *lowerCaseKeywordsSet = [[NSSet alloc] initWithArray:lowerCaseKeywords];
		self.keywords = lowerCaseKeywordsSet;
	}
	
    // begin command
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginCommand];
	if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.beginCommand = value;
	} else { 
		self.beginCommand = @"";
	}
    
    // end command
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndCommand];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.endCommand = value;
	} else { 
		self.endCommand = @"";
	}
    
    // begin instruction
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginInstruction];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.beginInstruction = value;
	} else {
		self.beginInstruction = @"";
	}

    // end instruction
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndInstruction];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.endInstruction = value;
	} else {
		self.endInstruction = @"";
	}
	
    // begin variable
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginVariable];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.beginVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:value];
	} else {
        self.beginVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
    }
	
    // end variable
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndVariable];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.endVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:value];
	} else {
		self.endVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
	}

    // first string
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionFirstString];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.firstString = value;
		if (![value isEqualToString:@""]) {
			firstStringUnichar = [value characterAtIndex:0];
		}
	} else {
		self.firstString = @"";
	}
	
    // second string
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionSecondString];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.secondString = value;
		if (![value isEqualToString:@""]) {
			secondStringUnichar = [value characterAtIndex:0];
		}
	} else { 
		self.secondString = @"";
	}
	
    // first single line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionFirstSingleLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.firstSingleLineComment = value;
	} else {
		self.firstSingleLineComment = @"";
	}
    
    self.singleLineComments = [NSMutableArray arrayWithCapacity:2];
    [self.singleLineComments addObject:firstSingleLineComment];
	
    // second single line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionSecondSingleLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.secondSingleLineComment = value;
	} else {
		self.secondSingleLineComment = @"";
	}
    [self.singleLineComments addObject:secondSingleLineComment];
	
    // begin first multi line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginFirstMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.beginFirstMultiLineComment = value;
	} else {
		self.beginFirstMultiLineComment = @"";
	}
	
    // end first multi line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndFirstMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.endFirstMultiLineComment = value;
	} else {
		self.endFirstMultiLineComment = @"";
	}

    self.multiLineComments = [NSMutableArray arrayWithCapacity:2];
	[self.multiLineComments addObject:[NSArray arrayWithObjects:self.beginFirstMultiLineComment, self.endFirstMultiLineComment, nil]];
	
    // begin second multi line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginSecondMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.beginSecondMultiLineComment = value;
	} else {
		self.beginSecondMultiLineComment = @"";
	}
     
    // end second multi line comment
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndSecondMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.endSecondMultiLineComment = value;
	} else {
		self.endSecondMultiLineComment = @"";
	}
	[self.multiLineComments addObject:[NSArray arrayWithObjects:self.beginSecondMultiLineComment, self.endSecondMultiLineComment, nil]];

	// function definition
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionFunctionDefinition];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.functionDefinition = value;
	} else {
		self.functionDefinition = @"";
	}
	
    // remove from function
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionRemoveFromFunction];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		self.removeFromFunction = value;
	} else {
		self.removeFromFunction = @"";
	}
	
    // exclude characters from keyword start character set
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionExcludeFromKeywordStartCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		NSMutableCharacterSet *temporaryCharacterSet = [keywordStartCharacterSet mutableCopy];
		[temporaryCharacterSet removeCharactersInString:value];
		self.keywordStartCharacterSet = [temporaryCharacterSet copy];
	}
	
    // exclude characters from keyword end character set
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionExcludeFromKeywordEndCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		NSMutableCharacterSet *temporaryCharacterSet = [keywordEndCharacterSet mutableCopy];
		[temporaryCharacterSet removeCharactersInString:value];
		self.keywordEndCharacterSet = [temporaryCharacterSet copy];
	}
	
    // include characters in keyword start character set
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionIncludeInKeywordStartCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		NSMutableCharacterSet *temporaryCharacterSet = [keywordStartCharacterSet mutableCopy];
		[temporaryCharacterSet addCharactersInString:value];
		self.keywordStartCharacterSet = [temporaryCharacterSet copy];
	}
	
    // include characters in keyword end character set
	value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionIncludeInKeywordEndCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
		NSMutableCharacterSet *temporaryCharacterSet = [keywordEndCharacterSet mutableCopy];
		[temporaryCharacterSet addCharactersInString:value];
		self.keywordEndCharacterSet = [temporaryCharacterSet copy];
	}

	[self prepareRegularExpressions];
}

/*
 
 - guessSyntaxDefinitionExtensionFromFirstLine:
 
 */
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine
{
	NSString *returnString = nil;
	NSRange firstLineRange = NSMakeRange(0, [firstLine length]);
	if ([firstLine rangeOfString:@"perl" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"pl";
	} else if ([firstLine rangeOfString:@"wish" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"tcl";
	} else if ([firstLine rangeOfString:@"sh" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"sh";
	} else if ([firstLine rangeOfString:@"php" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"php";
	} else if ([firstLine rangeOfString:@"python" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"py";
	} else if ([firstLine rangeOfString:@"awk" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"awk";
	} else if ([firstLine rangeOfString:@"xml" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"xml";
	} else if ([firstLine rangeOfString:@"ruby" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"rb";
	} else if ([firstLine rangeOfString:@"%!ps" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"ps";
	} else if ([firstLine rangeOfString:@"%pdf" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
		returnString = @"pdf";
	}
	
	return returnString;
}


#pragma mark -
#pragma mark Regex handling
/*
 
 - prepareRegularExpressions
 
 */
- (void)prepareRegularExpressions
{
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsColourMultiLineStrings] boolValue] == NO) {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\\\r\\n]*+)*+%@", self.firstString, self.firstString, self.firstString, self.firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\\\r\\n]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.secondString, self.secondString, self.secondString, self.secondString]];

	} else {
		firstStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.firstString, self.firstString, self.firstString, self.firstString]];
		
		secondStringPattern = [[ICUPattern alloc] initWithString:[NSString stringWithFormat:@"\\W%@[^%@\\\\]*+(?:\\\\(?:.|$)[^%@\\\\]*+)*+%@", self.secondString, self.secondString, self.secondString, self.secondString]];
	}
}


#pragma mark -
#pragma mark Accessors

/*
 
 - completeString
 
 */
- (NSString *)completeString
{
	return [[document valueForKey:ro_MGSFOTextView] string];
}

#pragma mark -
#pragma mark Colouring

/*
 
 - removeAllColours
 
 */
- (void)removeAllColours
{
	NSRange wholeRange = NSMakeRange(0, [[self completeString] length]);
	[firstLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:wholeRange];
}

/*
 
 - removeColoursFromRange
 
 */
- (void)removeColoursFromRange:(NSRange)range
{
	[firstLayoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
}

/*
 
 - pageRecolour
 
 */
- (void)pageRecolour
{
	[self pageRecolourTextView:[document valueForKey:ro_MGSFOTextView]];
}

/*
 
 - pageRecolourTextView:
 
 */
- (void)pageRecolourTextView:(SMLTextView *)textView
{
	if (!self.isSyntaxColouringRequired) {
		return;
	}
	
	if (textView == nil) {
		return;
	}
	NSRect visibleRect = [[[textView enclosingScrollView] contentView] documentVisibleRect];
	NSRange visibleRange = [[textView layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
	NSInteger beginningOfFirstVisibleLine = [[textView string] lineRangeForRange:NSMakeRange(visibleRange.location, 0)].location;
	NSInteger endOfLastVisibleLine = NSMaxRange([[self completeString] lineRangeForRange:NSMakeRange(NSMaxRange(visibleRange), 0)]);
	
	[self recolourRange:NSMakeRange(beginningOfFirstVisibleLine, endOfLastVisibleLine - beginningOfFirstVisibleLine)];
}

/*
 
 - pageRecolourTextView:options:
 
 */
- (void)pageRecolourTextView:(SMLTextView *)textView options:(NSDictionary *)options
{
	if (!textView) {
		return;
	}

	if (!self.isSyntaxColouringRequired) {
		return;
	}
	
	// colourAll option
	NSNumber *colourAll = [options objectForKey:@"colourAll"];
	if (!colourAll || ![colourAll boolValue]) {
		[self pageRecolourTextView:textView];
		return;
	}
	
	
	[self recolourRange:NSMakeRange(0, [[textView string] length])];
}

/*
 
 - recolourRange:
 
 */
- (void)recolourRange:(NSRange)rangeToRecolour
{
	if (reactToChanges == NO) {
		return;
	}

    // establish behavior
	BOOL shouldOnlyColourTillTheEndOfLine = [[SMLDefaults valueForKey:MGSFragariaPrefsOnlyColourTillTheEndOfLine] boolValue];
	BOOL shouldColourMultiLineStrings = [[SMLDefaults valueForKey:MGSFragariaPrefsColourMultiLineStrings] boolValue];
    	
    // setup
    NSString *documentString = [self completeString];
    NSUInteger documentStringLength = [documentString length];
	NSRange effectiveRange = rangeToRecolour;
	NSRange rangeOfLine = NSMakeRange(0, 0);
	NSRange foundRange = NSMakeRange(0, 0);
	NSRange searchRange = NSMakeRange(0, 0);
	NSUInteger searchSyntaxLength = 0;
	NSUInteger colourStartLocation = 0, colourEndLocation = 0, endOfLine = 0;
    NSUInteger colourLength = 0;
	NSUInteger endLocationInMultiLine = 0;
	NSUInteger beginLocationInMultiLine = 0;
	NSUInteger queryLocation = 0;
    unichar testCharacter = 0;
    
    // trace
    //NSLog(@"rangeToRecolor location %i length %i", rangeToRecolour.location, rangeToRecolour.length);
    
    // adjust effective range
    //
    // When multiline strings are coloured we need to scan backwards to
    // find where the string might have started if it's "above" the top of the screen.
    //
	if (shouldColourMultiLineStrings) { 
		NSInteger beginFirstStringInMultiLine = [documentString rangeOfString:self.firstString options:NSBackwardsSearch range:NSMakeRange(0, effectiveRange.location)].location;
		if (beginFirstStringInMultiLine != NSNotFound && [[firstLayoutManager temporaryAttributesAtCharacterIndex:beginFirstStringInMultiLine effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
			NSInteger startOfLine = [documentString lineRangeForRange:NSMakeRange(beginFirstStringInMultiLine, 0)].location;
			effectiveRange = NSMakeRange(startOfLine, rangeToRecolour.length + (rangeToRecolour.location - startOfLine));
		}
	}
	
    // setup working locations based on the effective range
	NSUInteger rangeLocation = effectiveRange.location;
	NSUInteger maxRangeLocation = NSMaxRange(effectiveRange);
    
    // assign range string
	NSString *rangeString = [documentString substringWithRange:effectiveRange];
	NSUInteger rangeStringLength = [rangeString length];
	if (rangeStringLength == 0) {
		return;
	}
    
    // allocate the range scanner
	NSScanner *rangeScanner = [[NSScanner alloc] initWithString:rangeString];
	[rangeScanner setCharactersToBeSkipped:nil];
    
    // allocate the document scanner
	NSScanner *documentScanner = [[NSScanner alloc] initWithString:documentString];
	[documentScanner setCharactersToBeSkipped:nil];
	
    // uncolour the range
	[self removeColoursFromRange:effectiveRange];
	
    // colouring delegate
    id colouringDelegate = [document valueForKey:MGSFOSyntaxColouringDelegate];
    BOOL delegateRespondsToShouldColourGroup = [colouringDelegate respondsToSelector:@selector(fragariaDocument:shouldColourGroupWithBlock:string:range:info:)];
    BOOL delegateRespondsToDidColourGroup = [colouringDelegate respondsToSelector:@selector(fragariaDocument:didColourGroupWithBlock:string:range:info:)];
    NSDictionary *delegateInfo =  nil;
	
    // define a block that the colour delegate can use to effect colouring
    BOOL (^colourRangeBlock)(NSDictionary *, NSRange) = ^(NSDictionary *colourInfo, NSRange range) {
        [self setColour:colourInfo range:range];
        
        // at the moment we always succeed
        return YES;
    };
    
    @try {
		
        BOOL doColouring = YES;
        
        //
        // query delegate about colouring the document
        //
        if ([colouringDelegate respondsToSelector:@selector(fragariaDocument:shouldColourWithBlock:string:range:info:)]) {
            
            // build minimal delegate info dictionary
            delegateInfo = @{SMLSyntaxInfo : self.syntaxDictionary, SMLSyntaxWillColour : @(self.isSyntaxColouringRequired)};
            
            // query delegate about colouring
            doColouring = [colouringDelegate fragariaDocument:document shouldColourWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
            
        }
        
        if (doColouring) {
            //
            // Numbers
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourNumbers] boolValue];
           
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupNumber, SMLSyntaxGroupID : @(kSMLSyntaxGroupNumber), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : numbersColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            } 
            
            // do colouring
            if (doColouring) {
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];

                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    
                    // scan up to a number character
                    [rangeScanner scanUpToCharactersFromSet:self.numberCharacterSet intoString:NULL];
                    colourStartLocation = [rangeScanner scanLocation];
                    
                    // scan to number end
                    [rangeScanner scanCharactersFromSet:self.numberCharacterSet intoString:NULL];
                    colourEndLocation = [rangeScanner scanLocation];
                    
                    if (colourStartLocation == colourEndLocation) {
                        break;
                    }
                    
                    // don't colour if preceding character is a letter.
                    // this prevents us from colouring numbers in variable names,
                    queryLocation = colourStartLocation + rangeLocation;
                    if (queryLocation > 0) {
                        testCharacter = [documentString characterAtIndex:queryLocation - 1];
                        
                        // numbers can occur in variable, class and function names
                        // eg: var_1 should not be coloured as a number
                        if ([self.nameCharacterSet characterIsMember:testCharacter]) {
                            continue;
                        }
                    }

                    // TODO: handle constructs such as 1..5 which may occur within some loop constructs
                    
                    // don't colour a trailing decimal point as some languages may use it as a line terminator
                    if (colourEndLocation > 0) {
                        queryLocation = colourEndLocation - 1;
                        testCharacter = [rangeString characterAtIndex:queryLocation];
                        if (testCharacter == self.decimalPointCharacter) {
                            colourEndLocation--;
                        }
                    }

                    [self setColour:numbersColour range:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)];
                }
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                } 
            }


            //
            // Commands
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourCommands] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupCommand, SMLSyntaxGroupID : @(kSMLSyntaxGroupCommand), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : commandsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            } 

            if (doColouring && ![self.beginCommand isEqualToString:@""]) {
                searchSyntaxLength = [self.endCommand length];
                unichar beginCommandCharacter = [self.beginCommand characterAtIndex:0];
                unichar endCommandCharacter = [self.endCommand characterAtIndex:0];
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];

                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    [rangeScanner scanUpToString:self.beginCommand intoString:nil];
                    colourStartLocation = [rangeScanner scanLocation];
                    endOfLine = NSMaxRange([rangeString lineRangeForRange:NSMakeRange(colourStartLocation, 0)]);
                    if (![rangeScanner scanUpToString:self.endCommand intoString:nil] || [rangeScanner scanLocation] >= endOfLine) {
                        [rangeScanner mgs_setScanLocation:endOfLine];
                        continue; // Don't colour it if it hasn't got a closing tag
                    } else {
                        // To avoid problems with strings like <yada <%=yada%> yada> we need to balance the number of begin- and end-tags
                        // If ever there's a beginCommand or endCommand with more than one character then do a check first
                        NSUInteger commandLocation = colourStartLocation + 1;
                        NSUInteger skipEndCommand = 0;
                        
                        while (commandLocation < endOfLine) {
                            unichar commandCharacterTest = [rangeString characterAtIndex:commandLocation];
                            if (commandCharacterTest == endCommandCharacter) {
                                if (!skipEndCommand) {
                                    break;
                                } else {
                                    skipEndCommand--;
                                }
                            }
                            if (commandCharacterTest == beginCommandCharacter) {
                                skipEndCommand++;
                            }
                            commandLocation++;
                        }
                        if (commandLocation < endOfLine) {
                            [rangeScanner mgs_setScanLocation:commandLocation + searchSyntaxLength];
                        } else {
                            [rangeScanner mgs_setScanLocation:endOfLine];
                        }
                    }
                    
                    [self setColour:commandsColour range:NSMakeRange(colourStartLocation + rangeLocation, [rangeScanner scanLocation] - colourStartLocation)];
                }

                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }
            


            //
            // Instructions
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourInstructions] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupInstruction, SMLSyntaxGroupID : @(kSMLSyntaxGroupInstruction), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : instructionsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }

            if (doColouring && ![self.beginInstruction isEqualToString:@""]) {
                // It takes too long to scan the whole document if it's large, so for instructions, first multi-line comment and second multi-line comment search backwards and begin at the start of the first beginInstruction etc. that it finds from the present position and, below, break the loop if it has passed the scanned range (i.e. after the end instruction)
                
                beginLocationInMultiLine = [documentString rangeOfString:self.beginInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                endLocationInMultiLine = [documentString rangeOfString:self.endInstruction options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
                    beginLocationInMultiLine = rangeLocation;
                }			

                searchSyntaxLength = [self.endInstruction length];

                // reset scanner
                [documentScanner mgs_setScanLocation:0];

                // scan document to end
                while (![documentScanner isAtEnd]) {
                    searchRange = NSMakeRange(beginLocationInMultiLine, rangeToRecolour.length);
                    if (NSMaxRange(searchRange) > documentStringLength) {
                        searchRange = NSMakeRange(beginLocationInMultiLine, documentStringLength - beginLocationInMultiLine);
                    }
                    
                    colourStartLocation = [documentString rangeOfString:self.beginInstruction options:NSLiteralSearch range:searchRange].location;
                    if (colourStartLocation == NSNotFound) {
                        break;
                    }
                    [documentScanner mgs_setScanLocation:colourStartLocation];
                    if (![documentScanner scanUpToString:self.endInstruction intoString:nil] || [documentScanner scanLocation] >= documentStringLength) {
                        if (shouldOnlyColourTillTheEndOfLine) {
                            [documentScanner mgs_setScanLocation:NSMaxRange([documentString lineRangeForRange:NSMakeRange(colourStartLocation, 0)])];
                        } else {
                            [documentScanner mgs_setScanLocation:documentStringLength];
                        }
                    } else {
                        if ([documentScanner scanLocation] + searchSyntaxLength <= documentStringLength) {
                            [documentScanner mgs_setScanLocation:[documentScanner scanLocation] + searchSyntaxLength];
                        }
                    }
                    
                    [self setColour:instructionsColour range:NSMakeRange(colourStartLocation, [documentScanner scanLocation] - colourStartLocation)];
                    if ([documentScanner scanLocation] > maxRangeLocation) {
                        break;
                    }
                    beginLocationInMultiLine = [documentScanner scanLocation];
                }

                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }


            //
            // Keywords
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourKeywords] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupKeyword, SMLSyntaxGroupID : @(kSMLSyntaxGroupKeyword), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : keywordsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
            
            if (doColouring && [keywords count] > 0) {
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];
                
                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    [rangeScanner scanUpToCharactersFromSet:self.keywordStartCharacterSet intoString:nil];
                    colourStartLocation = [rangeScanner scanLocation];
                    if ((colourStartLocation + 1) < rangeStringLength) {
                        [rangeScanner mgs_setScanLocation:(colourStartLocation + 1)];
                    }
                    [rangeScanner scanUpToCharactersFromSet:self.keywordEndCharacterSet intoString:nil];
                    
                    colourEndLocation = [rangeScanner scanLocation];
                    if (colourEndLocation > rangeStringLength || colourStartLocation == colourEndLocation) {
                        break;
                    }
                    
                    NSString *keywordTestString = nil;
                    if (!keywordsCaseSensitive) {
                        keywordTestString = [[documentString substringWithRange:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)] lowercaseString];
                    } else {
                        keywordTestString = [documentString substringWithRange:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)];
                    }
                    if ([keywords containsObject:keywordTestString]) {
                        if (!recolourKeywordIfAlreadyColoured) {
                            if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:colourStartLocation + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
                                continue;
                            }
                        }	
                        [self setColour:keywordsColour range:NSMakeRange(colourStartLocation + rangeLocation, [rangeScanner scanLocation] - colourStartLocation)];
                    }
                }
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }


            //
            // Autocomplete
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourAutocomplete] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupAutoComplete, SMLSyntaxGroupID : @(kSMLSyntaxGroupAutoComplete), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : autocompleteWordsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
            
            if (doColouring && [self.autocompleteWords count] > 0) {
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];
                
                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    [rangeScanner scanUpToCharactersFromSet:self.keywordStartCharacterSet intoString:nil];
                    colourStartLocation = [rangeScanner scanLocation];
                    if ((colourStartLocation + 1) < rangeStringLength) {
                        [rangeScanner mgs_setScanLocation:(colourStartLocation + 1)];
                    }
                    [rangeScanner scanUpToCharactersFromSet:self.keywordEndCharacterSet intoString:nil];
                    
                    colourEndLocation = [rangeScanner scanLocation];
                    if (colourEndLocation > rangeStringLength || colourStartLocation == colourEndLocation) {
                        break;
                    }
                    
                    NSString *autocompleteTestString = nil;
                    if (!keywordsCaseSensitive) {
                        autocompleteTestString = [[documentString substringWithRange:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)] lowercaseString];
                    } else {
                        autocompleteTestString = [documentString substringWithRange:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)];
                    }
                    if ([self.autocompleteWords containsObject:autocompleteTestString]) {
                        if (!recolourKeywordIfAlreadyColoured) {
                            if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:colourStartLocation + rangeLocation effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
                                continue;
                            }
                        }	
                        
                        [self setColour:autocompleteWordsColour range:NSMakeRange(colourStartLocation + rangeLocation, [rangeScanner scanLocation] - colourStartLocation)];
                    }
                }
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }
            

            //
            // Variables
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourVariables] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupVariable, SMLSyntaxGroupID : @(kSMLSyntaxGroupVariable), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : variablesColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
            
            if (doColouring && self.beginVariableCharacterSet != nil) {
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];
                
                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    [rangeScanner scanUpToCharactersFromSet:self.beginVariableCharacterSet intoString:nil];
                    colourStartLocation = [rangeScanner scanLocation];
                    if (colourStartLocation + 1 < rangeStringLength) {
                        if ([self.firstSingleLineComment isEqualToString:@"%"] && [rangeString characterAtIndex:colourStartLocation + 1] == '%') { // To avoid a problem in LaTex with \%
                            if ([rangeScanner scanLocation] < rangeStringLength) {
                                [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                            }
                            continue;
                        }
                    }
                    endOfLine = NSMaxRange([rangeString lineRangeForRange:NSMakeRange(colourStartLocation, 0)]);
                    if (![rangeScanner scanUpToCharactersFromSet:self.endVariableCharacterSet intoString:nil] || [rangeScanner scanLocation] >= endOfLine) {
                        [rangeScanner mgs_setScanLocation:endOfLine];
                        colourLength = [rangeScanner scanLocation] - colourStartLocation;
                    } else {
                        colourLength = [rangeScanner scanLocation] - colourStartLocation;
                        if ([rangeScanner scanLocation] < rangeStringLength) {
                            [rangeScanner mgs_setScanLocation:[rangeScanner scanLocation] + 1];
                        }
                    }
                    
                    [self setColour:variablesColour range:NSMakeRange(colourStartLocation + rangeLocation, colourLength)];
                }
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }


            //
            // Second string, first pass
            //

            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupSecondString, SMLSyntaxGroupID : @(kSMLSyntaxGroupSecondString), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : stringsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            } 

            if (doColouring && ![self.secondString isEqualToString:@""]) {
                
                @try {
                    secondStringMatcher = [[ICUMatcher alloc] initWithPattern:secondStringPattern overString:rangeString];
                }
                @catch (NSException *exception) {
                    return;
                }

                while ([secondStringMatcher findNext]) {
                    foundRange = [secondStringMatcher rangeOfMatch];
                    [self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
                }

                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }

            }


            //
            // First string
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupFirstString, SMLSyntaxGroupID : @(kSMLSyntaxGroupFirstString), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : stringsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
        
            if (doColouring && ![self.firstString isEqualToString:@""]) {
                
                @try {
                    firstStringMatcher = [[ICUMatcher alloc] initWithPattern:firstStringPattern overString:rangeString];
                }
                @catch (NSException *exception) {
                    return;
                }
                
                while ([firstStringMatcher findNext]) {
                    foundRange = [firstStringMatcher rangeOfMatch];
                    if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
                        continue;
                    }
                    [self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
                }

                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            
            }


            //
            // Attributes
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourAttributes] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupAttribute, SMLSyntaxGroupID : @(kSMLSyntaxGroupAttribute), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : attributesColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            } 

            if (doColouring) {
                
                // reset scanner
                [rangeScanner mgs_setScanLocation:0];
                
                // scan range to end
                while (![rangeScanner isAtEnd]) {
                    [rangeScanner scanUpToString:@" " intoString:nil];
                    colourStartLocation = [rangeScanner scanLocation];
                    if (colourStartLocation + 1 < rangeStringLength) {
                        [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                    } else {
                        break;
                    }
                    if (![[firstLayoutManager temporaryAttributesAtCharacterIndex:(colourStartLocation + rangeLocation) effectiveRange:NULL] isEqualToDictionary:commandsColour]) {
                        continue;
                    }
                    
                    [rangeScanner scanCharactersFromSet:self.attributesCharacterSet intoString:nil];
                    colourEndLocation = [rangeScanner scanLocation];
                    
                    if (colourEndLocation + 1 < rangeStringLength) {
                        [rangeScanner mgs_setScanLocation:[rangeScanner scanLocation] + 1];
                    }
                    
                    if ([documentString characterAtIndex:colourEndLocation + rangeLocation] == '=') {
                        [self setColour:attributesColour range:NSMakeRange(colourStartLocation + rangeLocation, colourEndLocation - colourStartLocation)];
                    }
                }

                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }

            }
            

            //
            // Colour single-line comments
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourComments] boolValue];
            
            // initial delegate group colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupSingleLineComment, SMLSyntaxGroupID : @(kSMLSyntaxGroupSingleLineComment), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : commentsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            } 

            if (doColouring) {
                for (NSString *singleLineComment in self.singleLineComments) {
                    if (![singleLineComment isEqualToString:@""]) {
                        
                        // reset scanner
                        [rangeScanner mgs_setScanLocation:0];
                        searchSyntaxLength = [singleLineComment length];
                        
                        // scan range to end
                        while (![rangeScanner isAtEnd]) {
                            
                            // scan for comment
                            [rangeScanner scanUpToString:singleLineComment intoString:nil];
                            colourStartLocation = [rangeScanner scanLocation];
                            
                            // common case handling
                            if ([singleLineComment isEqualToString:@"//"]) {
                                if (colourStartLocation > 0 && [rangeString characterAtIndex:colourStartLocation - 1] == ':') {
                                    [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                                    continue; // To avoid http:// ftp:// file:// etc.
                                }
                            } else if ([singleLineComment isEqualToString:@"#"]) {
                                if (rangeStringLength > 1) {
                                    rangeOfLine = [rangeString lineRangeForRange:NSMakeRange(colourStartLocation, 0)];
                                    if ([rangeString rangeOfString:@"#!" options:NSLiteralSearch range:rangeOfLine].location != NSNotFound) {
                                        [rangeScanner mgs_setScanLocation:NSMaxRange(rangeOfLine)];
                                        continue; // Don't treat the line as a comment if it begins with #!
                                    } else if (colourStartLocation > 0 && [rangeString characterAtIndex:colourStartLocation - 1] == '$') {
                                        [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                                        continue; // To avoid $#
                                    } else if (colourStartLocation > 0 && [rangeString characterAtIndex:colourStartLocation - 1] == '&') {
                                        [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                                        continue; // To avoid &#
                                    }
                                }
                            } else if ([singleLineComment isEqualToString:@"%"]) {
                                if (rangeStringLength > 1) {
                                    if (colourStartLocation > 0 && [rangeString characterAtIndex:colourStartLocation - 1] == '\\') {
                                        [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                                        continue; // To avoid \% in LaTex
                                    }
                                }
                            } 
                            
                            // If the comment is within an already coloured string then disregard it
                            if (colourStartLocation + rangeLocation + searchSyntaxLength < documentStringLength) {
                                if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:colourStartLocation + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
                                    [rangeScanner mgs_setScanLocation:colourStartLocation + 1];
                                    continue; 
                                }
                            }
                            
                            // this is a single line comment so we can scan to the end of the line
                            endOfLine = NSMaxRange([rangeString lineRangeForRange:NSMakeRange(colourStartLocation, 0)]);
                            [rangeScanner mgs_setScanLocation:endOfLine];
                            
                            // colour the comment
                            [self setColour:commentsColour range:NSMakeRange(colourStartLocation + rangeLocation, [rangeScanner scanLocation] - colourStartLocation)];
                        }
                    }
                } // end for
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }
            

            //
            // Multi-line comments
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourComments] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupMultiLineComment, SMLSyntaxGroupID : @(kSMLSyntaxGroupMultiLineComment), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : commentsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
        
            if (doColouring) {
                for (NSArray *multiLineComment in self.multiLineComments) {
                    
                    // Get strings
                    NSString *beginMultiLineComment = [multiLineComment objectAtIndex:0];
                    NSString *endMultiLineComment = [multiLineComment objectAtIndex:1];
                    
                    if (![beginMultiLineComment isEqualToString:@""]) {
                        
                        // Default to start of document
                        beginLocationInMultiLine = 0;
                        
                        // If start and end comment markers are the the same we
                        // always start searching at the beginning of the document.
                        // Otherwise we must consider that our start location may be mid way through
                        // a multiline comment.
                        if (![beginMultiLineComment isEqualToString:endMultiLineComment]) {
                            
                            // Search backwards from range location looking for comment start
                            beginLocationInMultiLine = [documentString rangeOfString:beginMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                            endLocationInMultiLine = [documentString rangeOfString:endMultiLineComment options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
                            
                            // If comments not found then begin at range location
                            if (beginLocationInMultiLine == NSNotFound || (endLocationInMultiLine != NSNotFound && beginLocationInMultiLine < endLocationInMultiLine)) {
                                beginLocationInMultiLine = rangeLocation;
                            }
                        }
                        
                        [documentScanner mgs_setScanLocation:beginLocationInMultiLine];
                        searchSyntaxLength = [endMultiLineComment length];
                        
                        // Iterate over the document until we exceed our work range
                        while (![documentScanner isAtEnd]) {
                            
                            // Search up to document end
                            searchRange = NSMakeRange(beginLocationInMultiLine, documentStringLength - beginLocationInMultiLine);
                            
                            // Look for comment start in document
                            colourStartLocation = [documentString rangeOfString:beginMultiLineComment options:NSLiteralSearch range:searchRange].location;
                            if (colourStartLocation == NSNotFound) {
                                break;
                            }
                            
                            // Increment our location.
                            // This is necessary to cover situations, such as F-Script, where the start and end comment strings are identical
                            if (colourStartLocation + 1 < documentStringLength) {
                                [documentScanner mgs_setScanLocation:colourStartLocation + 1];
                                
                                // If the comment is within a string disregard it
                                if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:colourStartLocation effectiveRange:NULL] isEqualToDictionary:stringsColour]) {
                                    beginLocationInMultiLine++;
                                    continue; 
                                }
                            } else {
                                [documentScanner mgs_setScanLocation:colourStartLocation];
                            }
                            
                            // Scan up to comment end
                            if (![documentScanner scanUpToString:endMultiLineComment intoString:nil] || [documentScanner scanLocation] >= documentStringLength) {
                                
                                // Comment end not found
                                if (shouldOnlyColourTillTheEndOfLine) {
                                    [documentScanner mgs_setScanLocation:NSMaxRange([documentString lineRangeForRange:NSMakeRange(colourStartLocation, 0)])];
                                } else {
                                    [documentScanner mgs_setScanLocation:documentStringLength];
                                }
                                colourLength = [documentScanner scanLocation] - colourStartLocation;
                            } else {
                                
                                // Comment end found
                                if ([documentScanner scanLocation] < documentStringLength) {
                                    
                                    // Safely advance scanner
                                    [documentScanner mgs_setScanLocation:[documentScanner scanLocation] + searchSyntaxLength];
                                }
                                colourLength = [documentScanner scanLocation] - colourStartLocation;
                                
                                // HTML specific
                                if ([endMultiLineComment isEqualToString:@"-->"]) {
                                    [documentScanner scanUpToCharactersFromSet:self.letterCharacterSet intoString:nil]; // Search for the first letter after -->
                                    if ([documentScanner scanLocation] + 6 < documentStringLength) {// Check if there's actually room for a </script>
                                        if ([documentString rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:NSMakeRange([documentScanner scanLocation] - 2, 9)].location != NSNotFound || [documentString rangeOfString:@"</style>" options:NSCaseInsensitiveSearch range:NSMakeRange([documentScanner scanLocation] - 2, 8)].location != NSNotFound) {
                                            beginLocationInMultiLine = [documentScanner scanLocation];
                                            continue; // If the comment --> is followed by </script> or </style> it is probably not a real comment
                                        }
                                    }
                                    [documentScanner mgs_setScanLocation:colourStartLocation + colourLength]; // Reset the scanner position
                                }
                            }

                            // Colour the range
                            [self setColour:commentsColour range:NSMakeRange(colourStartLocation, colourLength)];

                            // We may be done
                            if ([documentScanner scanLocation] > maxRangeLocation) {
                                break;
                            }
                            
                            // set start location for next search
                            beginLocationInMultiLine = [documentScanner scanLocation];
                        }
                    }
                } // end for
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
                
           }
        
            //
            // Second string, second pass
            //
            doColouring = [[SMLDefaults valueForKey:MGSFragariaPrefsColourStrings] boolValue];
            
            // query delegate about colouring
            if (delegateRespondsToShouldColourGroup) {
                
                // build delegate info dictionary
                delegateInfo = @{SMLSyntaxGroup : SMLSyntaxGroupSecondStringPass2, SMLSyntaxGroupID : @(kSMLSyntaxGroupSecondStringPass2), SMLSyntaxWillColour : @(doColouring), SMLSyntaxAttributes : stringsColour, SMLSyntaxInfo : self.syntaxDictionary};
                
                // call the delegate
                doColouring = [colouringDelegate fragariaDocument:document shouldColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
                
            }
        
            if (doColouring && ![self.secondString isEqualToString:@""]) {
                
                @try {
                    [secondStringMatcher reset];
                }
                @catch (NSException *exception) {
                    return;
                }
                
                while ([secondStringMatcher findNext]) {
                    foundRange = [secondStringMatcher rangeOfMatch];
                    if ([[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:stringsColour] || [[firstLayoutManager temporaryAttributesAtCharacterIndex:foundRange.location + rangeLocation effectiveRange:NULL] isEqualToDictionary:commentsColour]) {
                        continue;
                    }
                    [self setColour:stringsColour range:NSMakeRange(foundRange.location + rangeLocation + 1, foundRange.length - 1)];
                }
                
                // inform delegate that colouring is done
                if (delegateRespondsToDidColourGroup) {
                    [colouringDelegate fragariaDocument:document didColourGroupWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo];
                }
            }


            //
            // tell delegate we are did colour the document
            //
            if ([colouringDelegate respondsToSelector:@selector(fragariaDocument:didColourWithBlock:string:range:info:)]) {
                
                // build minimal delegate info dictionary
                delegateInfo = @{@"syntaxInfo" : self.syntaxDictionary};
                
                [colouringDelegate fragariaDocument:document didColourWithBlock:colourRangeBlock string:documentString range:rangeToRecolour info:delegateInfo ];
            }

        }

    }
	@catch (NSException *exception) {
		NSLog(@"Syntax colouring exception: %@", exception);
	}

    @try {
        //
        // highlight errors
        //
        [self highlightErrors];
	}
	@catch (NSException *exception) {
		NSLog(@"Error highlighting exception: %@", exception);
	}
	
}

/*
 
 - setColour:range:
 
 */
- (void)setColour:(NSDictionary *)colourDictionary range:(NSRange)range
{
	[firstLayoutManager setTemporaryAttributes:colourDictionary forCharacterRange:range];
}

/*
 
 - applyColourDefaults
 
 */
- (void)applyColourDefaults
{
	commandsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsCommandsColourWell]], NSForegroundColorAttributeName, nil];
	
	commentsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsCommentsColourWell]], NSForegroundColorAttributeName, nil];
	
	instructionsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsInstructionsColourWell]], NSForegroundColorAttributeName, nil];
	
	keywordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsKeywordsColourWell]], NSForegroundColorAttributeName, nil];
	
	autocompleteWordsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteColourWell]], NSForegroundColorAttributeName, nil];
	
	stringsColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsStringsColourWell]], NSForegroundColorAttributeName, nil];
	
	variablesColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsVariablesColourWell]], NSForegroundColorAttributeName, nil];
	
	attributesColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsAttributesColourWell]], NSForegroundColorAttributeName, nil];
	
	lineHighlightColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsHighlightLineColourWell]], NSBackgroundColorAttributeName, nil];

	numbersColour = [[NSDictionary alloc] initWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[SMLDefaults valueForKey:MGSFragariaPrefsNumbersColourWell]], NSForegroundColorAttributeName, nil];

}

/*
 
 - isSyntaxColouringRequired
 
 */
- (BOOL)isSyntaxColouringRequired
{
    return ([[document valueForKey:MGSFOIsSyntaxColoured] boolValue] && self.syntaxDefinitionAllowsColouring ? YES : NO);
}
/*
 
 - highlightLineRange:
 
 */
- (void)highlightLineRange:(NSRange)lineRange
{
	if (lineRange.location == lastLineHighlightRange.location && lineRange.length == lastLineHighlightRange.length) {
		return;
	}
	
	[firstLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:lastLineHighlightRange];
		
	[self pageRecolour];
	
	[firstLayoutManager addTemporaryAttributes:lineHighlightColour forCharacterRange:lineRange];
	
	lastLineHighlightRange = lineRange;
}

/*
 
 - characterIndexFromLine:character:inString:
 
 */
- (NSInteger) characterIndexFromLine:(int)line character:(int)character inString:(NSString*) str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    int currentLine = 1;
    while (![scanner isAtEnd])
    {
        if (currentLine == line)
        {
            // Found the right line
            NSInteger location = [scanner scanLocation] + character-1;
            if (location >= (NSInteger)str.length) location = str.length - 1;
            return location;
        }
        
        // Scan to a new line
        [scanner scanUpToString:@"\n" intoString:NULL];
        
        if (![scanner isAtEnd])
        {
            scanner.scanLocation += 1;
        }
        currentLine++;
    }
    
    return -1;
}

/*
 
 - highlightErrors
 
 */
- (void) highlightErrors
{
    SMLTextView* textView = [document valueForKey:ro_MGSFOTextView];
    NSString* text = [self completeString];
    
    // Clear all highlights
    [firstLayoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, text.length)];
    
    // Clear all buttons
    NSMutableArray* buttons = [NSMutableArray array];
    for (NSView* subview in [textView subviews])
    {
        if ([subview isKindOfClass:[NSButton class]])
        {
            [buttons addObject:subview];
        }
    }
    for (NSButton* button in buttons)
    {
        [button removeFromSuperview];
    }
    
    if (!syntaxErrors) return;
    
    // Highlight all errors and add buttons
    NSMutableSet* highlightedRows = [NSMutableSet set];

    for (SMLSyntaxError* err in syntaxErrors)
    {
        // Highlight an erronous line
        NSInteger location = [self characterIndexFromLine:err.line character:err.character inString:text];
        
        // Skip lines we cannot identify in the text
        if (location == -1) continue;
        
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(location, 0)];
     
        // Highlight row if it is not already highlighted
        if (![highlightedRows containsObject:[NSNumber numberWithInt:err.line]])
        {
            // Remember that we are highlighting this row
            [highlightedRows addObject:[NSNumber numberWithInt:err.line]];
            
            // Add highlight for background
            if (!err.customBackgroundColor) {
                [firstLayoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithCalibratedRed:1 green:1 blue:0.7 alpha:1] forCharacterRange:lineRange];
            } else {
                [firstLayoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:err.customBackgroundColor forCharacterRange:lineRange];
            }
            
            if ([err.description length] > 0)
                [firstLayoutManager addTemporaryAttribute:NSToolTipAttributeName value:err.description forCharacterRange:lineRange];
            
            if (!err.hideWarning) {
                NSInteger glyphIndex = [firstLayoutManager glyphIndexForCharacterAtIndex:lineRange.location];
                
                NSRect linePos = [firstLayoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:[textView textContainer]];
                
                // Add button
                float scrollOffset = textView.superview.bounds.origin.x - 0;
                
                NSButton* warningButton = [[NSButton alloc] initWithFrame:NSMakeRect(textView.superview.frame.size.width - 32 + scrollOffset, linePos.origin.y-2, 16, 16)];
                
                [warningButton setButtonType:NSMomentaryChangeButton];
                [warningButton setBezelStyle:NSRegularSquareBezelStyle];
                [warningButton setBordered:NO];
                [warningButton setImagePosition:NSImageOnly];
                [warningButton setImage:[MGSFragaria imageNamed:@"editor-warning.png"]];
                [warningButton setTag:err.line];
                [warningButton setTarget:self];
                [warningButton setAction:@selector(pressedWarningBtn:)];
                
                [textView addSubview:warningButton];
            }
        }
    }
}

/*
 
 - widthOfString:withFont:
 
 */
- (CGFloat) widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

#pragma mark -
#pragma mark Actions

/*
 
 - pressedWarningBtn
 
 */
- (void) pressedWarningBtn:(id) sender
{
    int line = (int)[sender tag];
    
    // Fetch errors to display
    NSMutableArray* errorsOnLine = [NSMutableArray array];
    for (SMLSyntaxError* err in syntaxErrors)
    {
        if (err.line == line)
        {
            [errorsOnLine addObject:err.description];
        }
    }
    
    if (errorsOnLine.count == 0) return;
    
    [SMLErrorPopOver showErrorDescriptions:errorsOnLine relativeToView:sender];
}

#pragma mark -
#pragma mark Document delegate support

/*
 
 - performDocumentDelegateSelector:withObject:
 
 */
- (void)performDocumentDelegateSelector:(SEL)selector withObject:(id)object
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[delegate performSelector:selector withObject:object];
#pragma clang diagnostic pop
	}
}


#pragma mark -
#pragma mark NSTextDelegate

/*
 
 - textDidChange:
 
 */
- (void)textDidChange:(NSNotification *)notification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:notification];

	if (reactToChanges == NO) {
		return;
	}
	NSString *completeString = [self completeString];
	
	if ([completeString length] < 2) {
		// MGS[SMLInterface updateStatusBar]; // One needs to call this from here as well because otherwise it won't update the status bar if one writes one character and deletes it in an empty document, because the textViewDidChangeSelection delegate method won't be called.
	}
	
	SMLTextView *textView = (SMLTextView *)[notification object];
	
	if ([[document valueForKey:MGSFOIsEdited] boolValue] == NO) {
		[document setValue:[NSNumber numberWithBool:YES] forKey:MGSFOIsEdited];
	}
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
		[self highlightLineRange:[completeString lineRangeForRange:[textView selectedRange]]];
	} else if ([self isSyntaxColouringRequired]) {
		[self pageRecolourTextView:textView];
	}
	
	if (autocompleteWordsTimer != nil) {
		[autocompleteWordsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:[[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteAfterDelay] floatValue]]];
	} else if ([[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteSuggestAutomatically] boolValue] == YES) {
		autocompleteWordsTimer = [NSTimer scheduledTimerWithTimeInterval:[[SMLDefaults valueForKey:MGSFragariaPrefsAutocompleteAfterDelay] floatValue] target:self selector:@selector(autocompleteWordsTimerSelector:) userInfo:textView repeats:NO];
	}
	
	[[document valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
	
}
/*
 
 - textDidBeginEditing:
 
 */
- (void)textDidBeginEditing:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];
}

/*
 
 - textDidEndEditing:
 
 */
- (void)textDidEndEditing:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];
}

/*
 
 - textShouldBeginEditing:
 
 */
- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:@selector(textShouldBeginEditing:)]) {
		return [delegate textShouldBeginEditing:aTextObject];
	}
	
	return YES;
}

/*
 
 - textShouldEndEditing:
 
 */
- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
	id delegate = [document valueForKey:MGSFODelegate]; 
	if (delegate && [delegate respondsToSelector:@selector(textShouldEndEditing:)]) {
		return [delegate textShouldEndEditing:aTextObject];
	}
	
	return YES;
}

#pragma mark -
#pragma mark NSTextViewDelegate

/*
 
 It would cumbersome to route all NSTextViewDelegate messages to our delegate.
 
 A better solution would be to permit subclasses of this class to be made the text view delegate.
 
 */
/*
 
 - textViewDidChangeTypingAttributes:
 
 */
- (void)textViewDidChangeTypingAttributes:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];

}

/*
 
 - textViewDidChangeSelection:
 
 */
- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
	// send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];

	if (reactToChanges == NO) {
		return;
	}
	
	NSString *completeString = [self completeString];

	NSUInteger completeStringLength = [completeString length];
	if (completeStringLength == 0) {
		return;
	}
	
	SMLTextView *textView = [aNotification object];
		
	NSRange editedRange = [textView selectedRange];
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsHighlightCurrentLine] boolValue] == YES) {
		[self highlightLineRange:[completeString lineRangeForRange:editedRange]];
	}
	
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsShowMatchingBraces] boolValue] == NO) {
		return;
	}

	
	NSUInteger cursorLocation = editedRange.location;
	NSInteger differenceBetweenLastAndPresent = cursorLocation - lastCursorLocation;
	lastCursorLocation = cursorLocation;
	if (differenceBetweenLastAndPresent != 1 && differenceBetweenLastAndPresent != -1) {
		return; // If the difference is more than one, they've moved the cursor with the mouse or it has been moved by resetSelectedRange below and we shouldn't check for matching braces then
	}
	
	if (differenceBetweenLastAndPresent == 1) { // Check if the cursor has moved forward
		cursorLocation--;
	}
	
	if (cursorLocation == completeStringLength) {
		return;
	}
	
	unichar characterToCheck = [completeString characterAtIndex:cursorLocation];
	NSInteger skipMatchingBrace = 0;
	
	if (characterToCheck == ')') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '(') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ')') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == ']') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '[') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == ']') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '}') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '{') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '}') {
				skipMatchingBrace++;
			}
		}
		NSBeep();
	} else if (characterToCheck == '>') {
		while (cursorLocation--) {
			characterToCheck = [completeString characterAtIndex:cursorLocation];
			if (characterToCheck == '<') {
				if (!skipMatchingBrace) {
					[textView showFindIndicatorForRange:NSMakeRange(cursorLocation, 1)];
					return;
				} else {
					skipMatchingBrace--;
				}
			} else if (characterToCheck == '>') {
				skipMatchingBrace++;
			}
		}
	}
	
}

/*
 
 - undoManagerForTextView:
 
 */
- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView
{
#pragma unused(aTextView)
	return undoManager;
}

#pragma mark -
#pragma mark MGSFragariaTextViewDelegate

/*
 
 - mgsTextDidPaste:
 
 */
- (void)mgsTextDidPaste:(NSNotification *)aNotification
{
    // send out document delegate notifications
	[self performDocumentDelegateSelector:_cmd withObject:aNotification];
}
#pragma mark -
#pragma mark Undo handling

/*
 
 - undoManagerDidUndo:
 
 */
- (void)undoManagerDidUndo:(NSNotification *)aNote
{
	NSUndoManager *theUndoManager = [aNote object];
	
	NSAssert([theUndoManager isKindOfClass:[NSUndoManager class]], @"bad notification object");
	
	if (![theUndoManager canUndo]) {
		
		// we can undo no more so we must be restored to unedited state
		[document setValue:[NSNumber numberWithBool:NO] forKey:MGSFOIsEdited];
		
		//should data be reloaded?
	}
}


#pragma mark -
#pragma mark NSTimer callbacks
/*
 
 - autocompleteWordsTimerSelector:
 
 */

- (void)autocompleteWordsTimerSelector:(NSTimer *)theTimer
{
	SMLTextView *textView = [theTimer userInfo];
	NSRange selectedRange = [textView selectedRange];
	NSString *completeString = [self completeString];
	NSUInteger stringLength = [completeString length];
    
	if (selectedRange.location <= stringLength && selectedRange.length == 0 && stringLength != 0) {
		if (selectedRange.location == stringLength) { // If we're at the very end of the document
			[textView complete:nil];
		} else {
			unichar characterAfterSelection = [completeString characterAtIndex:selectedRange.location];
			if ([[NSCharacterSet symbolCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:characterAfterSelection] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:characterAfterSelection] || selectedRange.location == stringLength) { // Don't autocomplete if we're in the middle of a word
				[textView complete:nil];
			}
		}
	}
	
	if (autocompleteWordsTimer) {
		[autocompleteWordsTimer invalidate];
		autocompleteWordsTimer = nil;
	}
}

#pragma mark -
#pragma mark SMLAutoCompleteDelegate

/*
 
 - completions
 
 */
- (NSArray*) completions
{
    return self.keywordsAndAutocompleteWords;
}
@end