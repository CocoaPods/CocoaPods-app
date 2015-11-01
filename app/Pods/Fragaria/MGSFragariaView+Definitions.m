//
//  MGSFragariaView+Definitions.m
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//
#import "MGSFragariaView.h"
#import "MGSFragariaView+Definitions.h"
#import "MGSSyntaxController.h"


#pragma mark - Property User Defaults Keys


// Configuring Syntax Highlighting
NSString * const MGSFragariaDefaultsIsSyntaxColoured =          @"syntaxColoured";
NSString * const MGSFragariaDefaultsSyntaxDefinitionName =      @"syntaxDefinitionName";
NSString * const MGSFragariaDefaultsColoursMultiLineStrings =   @"coloursMultiLineStrings";
NSString * const MGSFragariaDefaultsColoursOnlyUntilEndOfLine = @"coloursOnlyUntilEndOfLine";

// Configuring Autocompletion
NSString * const MGSFragariaDefaultsAutoCompleteDelay =        @"autoCompleteDelay";
NSString * const MGSFragariaDefaultsAutoCompleteEnabled =      @"autoCompleteEnabled";
NSString * const MGSFragariaDefaultsAutoCompleteWithKeywords = @"autoCompleteWithKeywords";

// Highlighting the current line
NSString * const MGSFragariaDefaultsCurrentLineHighlightColour = @"currentLineHighlightColour";
NSString * const MGSFragariaDefaultsHighlightsCurrentLine =      @"highlightsCurrentLine";

// Configuring the Gutter
NSString * const MGSFragariaDefaultsShowsGutter =        @"showsGutter";
NSString * const MGSFragariaDefaultsMinimumGutterWidth = @"minimumGutterWidth";
NSString * const MGSFragariaDefaultsShowsLineNumbers =   @"showsLineNumbers";
NSString * const MGSFragariaDefaultsStartingLineNumber = @"startingLineNumber";
NSString * const MGSFragariaDefaultsGutterFont =         @"gutterFont";
NSString * const MGSFragariaDefaultsGutterTextColour =   @"gutterTextColour";

// Showing Syntax Errors
NSString * const MGSFragariaDefaultsShowsSyntaxErrors =             @"showsSyntaxErrors";
NSString * const MGSFragariaDefaultsShowsIndividualErrors =         @"showsIndividualErrors";
NSString * const MGSFragariaDefaultsDefaultErrorHighlightingColor = @"defaultSyntaxErrorHighlightingColour";

// Tabulation and Indentation
NSString * const MGSFragariaDefaultsTabWidth =                    @"tabWidth";
NSString * const MGSFragariaDefaultsIndentWidth =                 @"indentWidth";
NSString * const MGSFragariaDefaultsIndentWithSpaces =            @"indentWithSpaces";
NSString * const MGSFragariaDefaultsUseTabStops =                 @"useTabStops";
NSString * const MGSFragariaDefaultsIndentBracesAutomatically =   @"indentBracesAutomatically";
NSString * const MGSFragariaDefaultsIndentNewLinesAutomatically = @"indentNewLinesAutomatically";

// Automatic Bracing
NSString * const MGSFragariaDefaultsInsertClosingBraceAutomatically =       @"insertClosingBraceAutomatically";
NSString * const MGSFragariaDefaultsInsertClosingParenthesisAutomatically = @"insertClosingParenthesisAutomatically";
NSString * const MGSFragariaDefaultsShowsMatchingBraces =                   @"showsMatchingBraces";

// Page Guide and Line Wrap
NSString * const MGSFragariaDefaultsPageGuideColumn =      @"pageGuideColumn";
NSString * const MGSFragariaDefaultsShowsPageGuide =       @"showsPageGuide";
NSString * const MGSFragariaDefaultsLineWrap =             @"lineWrap";
NSString * const MGSFragariaDefaultsLineWrapsAtPageGuide = @"lineWrapsAtPageGuide";

// Showing Invisible Characters
NSString * const MGSFragariaDefaultsShowsInvisibleCharacters =      @"showsInvisibleCharacters";
NSString * const MGSFragariaDefaultsTextInvisibleCharactersColour = @"textInvisibleCharactersColour";

// Configuring Text Appearance
NSString * const MGSFragariaDefaultsTextColor =       @"textColor";
NSString * const MGSFragariaDefaultsBackgroundColor = @"backgroundColor";
NSString * const MGSFragariaDefaultsTextFont =        @"textFont";
NSString * const MGSFragariaDefaultsLineHeightMultiple = @"lineHeightMultiple";

// Configuring Additional Text View Behavior
NSString * const MGSFragariaDefaultsHasVerticalScroller =      @"hasVerticalScroller";
NSString * const MGSFragariaDefaultsInsertionPointColor =      @"insertionPointColor";
NSString * const MGSFragariaDefaultsScrollElasticityDisabled = @"scrollElasticityDisabled";

// Syntax Highlighting Colours
NSString * const MGSFragariaDefaultsColourForAutocomplete = @"colourForAutocomplete";
NSString * const MGSFragariaDefaultsColourForAttributes =   @"colourForAttributes";
NSString * const MGSFragariaDefaultsColourForCommands =     @"colourForCommands";
NSString * const MGSFragariaDefaultsColourForComments =     @"colourForComments";
NSString * const MGSFragariaDefaultsColourForInstructions = @"colourForInstructions";
NSString * const MGSFragariaDefaultsColourForKeywords =     @"colourForKeywords";
NSString * const MGSFragariaDefaultsColourForNumbers =      @"colourForNumbers";
NSString * const MGSFragariaDefaultsColourForStrings =      @"colourForStrings";
NSString * const MGSFragariaDefaultsColourForVariables =    @"colourForVariables";

// Syntax Highlighter Colouring Options
NSString * const MGSFragariaDefaultsColoursAttributes =   @"coloursAttributes";
NSString * const MGSFragariaDefaultsColoursAutocomplete = @"coloursAutocomplete";
NSString * const MGSFragariaDefaultsColoursCommands =     @"coloursCommands";
NSString * const MGSFragariaDefaultsColoursComments =     @"coloursComments";
NSString * const MGSFragariaDefaultsColoursInstructions = @"coloursInstructions";
NSString * const MGSFragariaDefaultsColoursKeywords =     @"coloursKeywords";
NSString * const MGSFragariaDefaultsColoursNumbers =      @"coloursNumbers";
NSString * const MGSFragariaDefaultsColoursStrings =      @"coloursStrings";
NSString * const MGSFragariaDefaultsColoursVariables =    @"coloursVariables";


#pragma mark - Implementation


@implementation MGSFragariaView (MGSUserDefaultsDefinitions)


#pragma mark - Defaults Dictionaries


#define ARCHIVED_COLOR(rd, gr, bl) [NSArchiver archivedDataWithRootObject:\
[NSColor colorWithCalibratedRed:rd green:gr blue:bl alpha:1.0f]]
#define ARCHIVED_OBJECT(obj) [NSArchiver archivedDataWithRootObject:obj]

/*
 *  + fragariaDefaultsDictionary
 */
+ (NSDictionary *)defaultsDictionary
{
	return @{
		 MGSFragariaDefaultsIsSyntaxColoured : @YES,
		 MGSFragariaDefaultsSyntaxDefinitionName : [[MGSSyntaxController class] standardSyntaxDefinitionName],
		 MGSFragariaDefaultsColoursMultiLineStrings : @NO,
		 MGSFragariaDefaultsColoursOnlyUntilEndOfLine : @YES,

 		 MGSFragariaDefaultsAutoCompleteDelay : @1.0f,
		 MGSFragariaDefaultsAutoCompleteEnabled : @NO,
		 MGSFragariaDefaultsAutoCompleteWithKeywords : @YES,

		 MGSFragariaDefaultsCurrentLineHighlightColour : ARCHIVED_COLOR(0.96f,0.96f,0.71f),
		 MGSFragariaDefaultsHighlightsCurrentLine : @NO,

		 MGSFragariaDefaultsShowsGutter : @YES,
		 MGSFragariaDefaultsMinimumGutterWidth : @40,
		 MGSFragariaDefaultsShowsLineNumbers : @YES,
		 MGSFragariaDefaultsStartingLineNumber : @1,
		 MGSFragariaDefaultsGutterFont : ARCHIVED_OBJECT([NSFont fontWithName:@"Menlo" size:11]),
		 MGSFragariaDefaultsGutterTextColour : ARCHIVED_OBJECT([NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]),

		 MGSFragariaDefaultsShowsSyntaxErrors : @YES,
		 MGSFragariaDefaultsShowsIndividualErrors : @NO,
         MGSFragariaDefaultsDefaultErrorHighlightingColor : ARCHIVED_COLOR(1.0f, 1.0f, 0.7f),

		 MGSFragariaDefaultsTabWidth : @4,
		 MGSFragariaDefaultsIndentWidth : @4,
		 MGSFragariaDefaultsUseTabStops : @YES,
		 MGSFragariaDefaultsIndentWithSpaces : @NO,
		 MGSFragariaDefaultsIndentBracesAutomatically : @YES,
		 MGSFragariaDefaultsIndentNewLinesAutomatically : @YES,
         MGSFragariaDefaultsLineHeightMultiple : @(0.0),
		 
		 MGSFragariaDefaultsInsertClosingBraceAutomatically : @NO,
		 MGSFragariaDefaultsInsertClosingParenthesisAutomatically : @NO,
		 MGSFragariaDefaultsShowsMatchingBraces : @YES,
		 
		 MGSFragariaDefaultsPageGuideColumn : @80,
		 MGSFragariaDefaultsShowsPageGuide : @NO,
		 MGSFragariaDefaultsLineWrap : @YES,
         MGSFragariaDefaultsLineWrapsAtPageGuide : @NO,
		 MGSFragariaDefaultsShowsInvisibleCharacters : @NO,
		 MGSFragariaDefaultsTextInvisibleCharactersColour : ARCHIVED_OBJECT([NSColor controlTextColor]),

		 MGSFragariaDefaultsTextColor : ARCHIVED_OBJECT([NSColor textColor]),
		 MGSFragariaDefaultsBackgroundColor : ARCHIVED_OBJECT([NSColor whiteColor]),
		 MGSFragariaDefaultsTextFont : ARCHIVED_OBJECT([NSFont fontWithName:@"Menlo" size:11]),

		 MGSFragariaDefaultsHasVerticalScroller : @YES,
		 MGSFragariaDefaultsInsertionPointColor : ARCHIVED_OBJECT([NSColor textColor]),
		 MGSFragariaDefaultsScrollElasticityDisabled : @NO,
	
		 MGSFragariaDefaultsColourForAutocomplete : ARCHIVED_COLOR(0.84f,0.41f,0.006f),
		 MGSFragariaDefaultsColourForAttributes : ARCHIVED_COLOR(0.50f,0.5f,0.2f),
		 MGSFragariaDefaultsColourForCommands : ARCHIVED_COLOR(0.031f,0.0f,0.855f),
		 MGSFragariaDefaultsColourForComments : ARCHIVED_COLOR(0.0f,0.45f,0.0f),
		 MGSFragariaDefaultsColourForInstructions : ARCHIVED_COLOR(0.737f,0.0f,0.647f),
		 MGSFragariaDefaultsColourForKeywords : ARCHIVED_COLOR(0.737f,0.0f,0.647f),
		 MGSFragariaDefaultsColourForNumbers : ARCHIVED_COLOR(0.031f,0.0f,0.855f),
		 MGSFragariaDefaultsColourForStrings : ARCHIVED_COLOR(0.804f,0.071f,0.153f),
		 MGSFragariaDefaultsColourForVariables : ARCHIVED_COLOR(0.73f,0.0f,0.74f),
		 
		 MGSFragariaDefaultsColoursAttributes : @YES,
		 MGSFragariaDefaultsColoursAutocomplete : @NO,
		 MGSFragariaDefaultsColoursCommands : @YES,
		 MGSFragariaDefaultsColoursComments : @YES,
		 MGSFragariaDefaultsColoursInstructions : @YES,
		 MGSFragariaDefaultsColoursKeywords : @YES,
		 MGSFragariaDefaultsColoursNumbers : @YES,
		 MGSFragariaDefaultsColoursStrings : @YES,
		 MGSFragariaDefaultsColoursVariables : @YES,
    };
}


#pragma mark - Manual Management Support

/*
 *  + fragariaNamespacedKeyForKey:
 */
+ (NSString *)namespacedKeyForKey:(NSString *)aString
{
	NSString *character = [[aString substringToIndex:1] uppercaseString];
	NSMutableString *changedString = [NSMutableString stringWithString:aString];
	[changedString replaceCharactersInRange:NSMakeRange(0, 1) withString:character];
	return [NSString stringWithFormat:@"MGSFragariaDefaults%@", changedString];
}


/*
 *  + fragariaDefaultsDictionaryWithNamespace
 */
+ (NSDictionary *)defaultsDictionaryWithNamespace
{
    __block NSMutableDictionary *dictionary;
    NSDictionary *def;
    
    dictionary = [[NSMutableDictionary alloc] init];
    def = [[self class] defaultsDictionary];
    
	[def enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        [dictionary setObject:object forKey:[self namespacedKeyForKey:key]];
	}];
    
	return [dictionary copy];
}


/*
 *  + applyDefaultsToFragariaView
 */
- (void)resetDefaults
{
    NSDictionary *def;
    
    def = [[self class] defaultsDictionary];
    
	for (NSString *key in def)
		[self setValue:def[key] forKey:key];
}


#pragma mark - Class Methods - Convenience Sets of Properties


/*
 * + propertyGroupEditing
 */
+ (NSSet *)propertyGroupEditing
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsIsSyntaxColoured,
        MGSFragariaDefaultsHighlightsCurrentLine, MGSFragariaDefaultsPageGuideColumn,
		MGSFragariaDefaultsShowsSyntaxErrors, MGSFragariaDefaultsShowsIndividualErrors,
		MGSFragariaDefaultsShowsPageGuide, MGSFragariaDefaultsLineWrap,
		MGSFragariaDefaultsLineWrapsAtPageGuide, MGSFragariaDefaultsShowsInvisibleCharacters,
		MGSFragariaDefaultsLineHeightMultiple, MGSFragariaDefaultsShowsMatchingBraces,
	]];
}


/*
 * + propertyGroupGutter
 */
+ (NSSet *)propertyGroupGutter
{
    return [NSSet setWithArray:@[MGSFragariaDefaultsMinimumGutterWidth,
        MGSFragariaDefaultsShowsGutter, MGSFragariaDefaultsShowsLineNumbers,
	]];
}

/*
 * + propertyGroupAutocomplete
 */
+ (NSSet *)propertyGroupAutocomplete
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsAutoCompleteDelay,
		MGSFragariaDefaultsAutoCompleteEnabled, MGSFragariaDefaultsAutoCompleteWithKeywords,
		MGSFragariaDefaultsInsertClosingBraceAutomatically,
        MGSFragariaDefaultsInsertClosingParenthesisAutomatically,
	]];
}


/*
 * + propertyGroupIndenting
 */
+ (NSSet *)propertyGroupIndenting
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsTabWidth,
        MGSFragariaDefaultsIndentWidth, MGSFragariaDefaultsIndentWithSpaces,
		MGSFragariaDefaultsUseTabStops, MGSFragariaDefaultsIndentBracesAutomatically,
		MGSFragariaDefaultsIndentNewLinesAutomatically
	]];
}


/*
 * + propertyGroupTextFont
 */
+ (NSSet *)propertyGroupTextFont
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsTextFont]];
}


/*
 * + propertyGroupEditorColours
 */
+ (NSSet *)propertyGroupEditorColours
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsInsertionPointColor,
        MGSFragariaDefaultsCurrentLineHighlightColour,
        MGSFragariaDefaultsDefaultErrorHighlightingColor,
        MGSFragariaDefaultsTextColor, MGSFragariaDefaultsBackgroundColor,
		MGSFragariaDefaultsTextInvisibleCharactersColour,
	]];
}


/*
 * + propertyGroupSyntaxHighlightingColours
 */
+ (NSSet *)propertyGroupSyntaxHighlightingColours
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsColourForAutocomplete,
        MGSFragariaDefaultsColourForAttributes, MGSFragariaDefaultsColourForCommands,
		MGSFragariaDefaultsColourForComments, MGSFragariaDefaultsColourForInstructions,
		MGSFragariaDefaultsColourForKeywords, MGSFragariaDefaultsColourForNumbers,
		MGSFragariaDefaultsColourForStrings, MGSFragariaDefaultsColourForVariables,
	]];
}


/*
 * + propertyGroupSyntaxHighlightingBools
 */
+ (NSSet *)propertyGroupSyntaxHighlightingBools
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsColoursAttributes,
        MGSFragariaDefaultsColoursAutocomplete, MGSFragariaDefaultsColoursCommands,
		MGSFragariaDefaultsColoursComments, MGSFragariaDefaultsColoursInstructions,
		MGSFragariaDefaultsColoursKeywords, MGSFragariaDefaultsColoursNumbers,
		MGSFragariaDefaultsColoursStrings, MGSFragariaDefaultsColoursVariables,
	]];
}


/*
 * - propertyGroupSyntaxHighlighting
 */
+ (NSSet *)propertyGroupSyntaxHighlighting
{
	return [[[self class] propertyGroupSyntaxHighlightingColours]
			setByAddingObjectsFromSet:[[self class] propertyGroupSyntaxHighlightingBools]];
}


/*
 * + propertyGroupTheme
 */
+ (NSSet *)propertyGroupTheme
{
	return [[[self class] propertyGroupEditorColours]
			setByAddingObjectsFromSet:[[self class] propertyGroupSyntaxHighlighting]];
}


/*
 * + propertyGroupColouringExtraOptions
 */
+ (NSSet *)propertyGroupColouringExtraOptions
{
	return [NSSet setWithArray:@[MGSFragariaDefaultsColoursMultiLineStrings,
        MGSFragariaDefaultsColoursOnlyUntilEndOfLine]];
}


@end
