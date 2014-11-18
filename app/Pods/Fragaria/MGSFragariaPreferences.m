//
//  MGSFragariaPreferences.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "MGSFragariaPreferences.h"

// colour prefs
// persisted as [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
NSString * const MGSFragariaPrefsCommandsColourWell = @"FragariaCommandsColourWell";
NSString * const MGSFragariaPrefsCommentsColourWell = @"FragariaCommentsColourWell";
NSString * const MGSFragariaPrefsInstructionsColourWell = @"FragariaInstructionsColourWell";
NSString * const MGSFragariaPrefsKeywordsColourWell = @"FragariaKeywordsColourWell";
NSString * const MGSFragariaPrefsAutocompleteColourWell = @"FragariaAutocompleteColourWell";
NSString * const MGSFragariaPrefsVariablesColourWell = @"FragariaVariablesColourWell";
NSString * const MGSFragariaPrefsStringsColourWell = @"FragariaStringsColourWell";
NSString * const MGSFragariaPrefsAttributesColourWell = @"FragariaAttributesColourWell";
NSString * const MGSFragariaPrefsNumbersColourWell = @"FragariaNumbersColourWell";
NSString * const MGSFragariaPrefsBackgroundColourWell = @"FragariaBackgroundColourWell";
NSString * const MGSFragariaPrefsTextColourWell = @"FragariaTextColourWell";
NSString * const MGSFragariaPrefsGutterTextColourWell = @"FragariaGutterTextColourWell";
NSString * const MGSFragariaPrefsInvisibleCharactersColourWell = @"FragariaInvisibleCharactersColourWell";
NSString * const MGSFragariaPrefsHighlightLineColourWell = @"FragariaHighlightLineColourWell";

// bool
NSString * const MGSFragariaPrefsColourNumbers = @"FragariaColourNumbers";
NSString * const MGSFragariaPrefsColourCommands = @"FragariaColourCommands";
NSString * const MGSFragariaPrefsColourComments = @"FragariaColourComments";
NSString * const MGSFragariaPrefsColourInstructions = @"FragariaColourInstructions";
NSString * const MGSFragariaPrefsColourKeywords = @"FragariaColourKeywords";
NSString * const MGSFragariaPrefsColourAutocomplete = @"FragariaColourAutocomplete";
NSString * const MGSFragariaPrefsColourVariables = @"FragariaColourVariables";
NSString * const MGSFragariaPrefsColourStrings = @"FragariaColourStrings";
NSString * const MGSFragariaPrefsColourAttributes = @"FragariaColourAttributes";
NSString * const MGSFragariaPrefsShowFullPathInWindowTitle = @"FragariaShowFullPathInWindowTitle";
NSString * const MGSFragariaPrefsShowLineNumberGutter = @"FragariaShowLineNumberGutter";
NSString * const MGSFragariaPrefsSyntaxColourNewDocuments = @"FragariaSyntaxColourNewDocuments";
NSString * const MGSFragariaPrefsLineWrapNewDocuments = @"FragariaLineWrapNewDocuments";
NSString * const MGSFragariaPrefsIndentNewLinesAutomatically = @"FragariaIndentNewLinesAutomatically";
NSString * const MGSFragariaPrefsOnlyColourTillTheEndOfLine = @"FragariaOnlyColourTillTheEndOfLine";
NSString * const MGSFragariaPrefsShowMatchingBraces = @"FragariaShowMatchingBraces";
NSString * const MGSFragariaPrefsShowInvisibleCharacters = @"FragariaShowInvisibleCharacters";
NSString * const MGSFragariaPrefsIndentWithSpaces = @"FragariaIndentWithSpaces";
NSString * const MGSFragariaPrefsColourMultiLineStrings = @"FragariaColourMultiLineStrings";
NSString * const MGSFragariaPrefsAutocompleteSuggestAutomatically = @"FragariaAutocompleteSuggestAutomatically";
NSString * const MGSFragariaPrefsAutocompleteIncludeStandardWords = @"FragariaAutocompleteIncludeStandardWords";
NSString * const MGSFragariaPrefsAutoSpellCheck = @"FragariaAutoSpellCheck";
NSString * const MGSFragariaPrefsAutoGrammarCheck = @"FragariaAutoGrammarCheck";
NSString * const MGSFragariaPrefsSmartInsertDelete = @"FragariaSmartInsertDelete";
NSString * const MGSFragariaPrefsAutomaticLinkDetection = @"FragariaAutomaticLinkDetection";
NSString * const MGSFragariaPrefsAutomaticQuoteSubstitution = @"FragariaAutomaticQuoteSubstitution";
NSString * const MGSFragariaPrefsUseTabStops = @"FragariaUseTabStops";
NSString * const MGSFragariaPrefsHighlightCurrentLine = @"FragariaHighlightCurrentLine";
NSString * const MGSFragariaPrefsAutomaticallyIndentBraces = @"FragariaAutomaticallyIndentBraces";
NSString * const MGSFragariaPrefsAutoInsertAClosingParenthesis = @"FragariaAutoInsertAClosingParenthesis";
NSString * const MGSFragariaPrefsAutoInsertAClosingBrace = @"FragariaAutoInsertAClosingBrace";
NSString * const MGSFragariaPrefsShowPageGuide = @"FragariaShowPageGuide";

// integer
NSString * const MGSFragariaPrefsGutterWidth = @"FragariaGutterWidth";
NSString * const MGSFragariaPrefsTabWidth = @"FragariaTabWidth";
NSString * const MGSFragariaPrefsIndentWidth = @"FragariaIndentWidth";
NSString * const MGSFragariaPrefsShowPageGuideAtColumn = @"FragariaShowPageGuideAtColumn";
NSString * const MGSFragariaPrefsSpacesPerTabEntabDetab = @"FragariaSpacesPerTabEntabDetab";

// float
NSString * const MGSFragariaPrefsAutocompleteAfterDelay = @"FragariaAutocompleteAfterDelay";

// font
// persisted as [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
NSString * const MGSFragariaPrefsTextFont = @"FragariaTextFont";

// string
NSString * const MGSFragariaPrefsSyntaxColouringPopUpString = @"FragariaSyntaxColouringPopUpString";

static BOOL MGS_preferencesInitialized = NO;
static id sharedInstance = nil;

@implementation MGSFragariaPreferences

@synthesize fontsAndColoursPrefsViewController, textEditingPrefsViewController;

/*
 
 - initializeValues
 
 */
+ (void)initializeValues
{
	if (MGS_preferencesInitialized) {
		return;
	}
    
    // add to initial values
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[defaultsController initialValues]];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031f green:0.0f blue:0.855f alpha:1.0f]] forKey:MGSFragariaPrefsCommandsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0f green:0.45f blue:0.0f alpha:1.0f]] forKey:MGSFragariaPrefsCommentsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.45f green:0.45f blue:0.45f alpha:1.0f]] forKey:MGSFragariaPrefsInstructionsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.737f green:0.0f blue:0.647f alpha:1.0f]] forKey:MGSFragariaPrefsKeywordsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.84f green:0.41f blue:0.006f alpha:1.0f]] forKey:MGSFragariaPrefsAutocompleteColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.73f green:0.0f blue:0.74f alpha:1.0f]] forKey:MGSFragariaPrefsVariablesColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.804f green:0.071f blue:0.153f alpha:1.0f]] forKey:MGSFragariaPrefsStringsColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.50f green:0.5f blue:0.2f alpha:1.0f]] forKey:MGSFragariaPrefsAttributesColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.031f green:0.0f blue:0.855f alpha:1.0f]] forKey:MGSFragariaPrefsNumbersColourWell];
    
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourNumbers];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourCommands];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourInstructions];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourKeywords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsColourAutocomplete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourVariables];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourStrings];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourAttributes];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsColourComments];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:MGSFragariaPrefsBackgroundColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor textColor]] forKey:MGSFragariaPrefsTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.42f alpha:1.0f]] forKey:MGSFragariaPrefsGutterTextColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor orangeColor]] forKey:MGSFragariaPrefsInvisibleCharactersColourWell];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.96f green:0.96f blue:0.71f alpha:1.0f]] forKey:MGSFragariaPrefsHighlightLineColourWell];
	
	[dictionary setValue:[NSNumber numberWithInteger:40] forKey:MGSFragariaPrefsGutterWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsTabWidth];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsIndentWidth];
    [dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsShowPageGuide];
	[dictionary setValue:[NSNumber numberWithInteger:80] forKey:MGSFragariaPrefsShowPageGuideAtColumn];
	[dictionary setValue:[NSNumber numberWithFloat:1.0f] forKey:MGSFragariaPrefsAutocompleteAfterDelay];
	
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]] forKey:MGSFragariaPrefsTextFont];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowFullPathInWindowTitle];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowLineNumberGutter];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsSyntaxColourNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsLineWrapNewDocuments];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsIndentNewLinesAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsOnlyColourTillTheEndOfLine];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsShowMatchingBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsShowInvisibleCharacters];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsIndentWithSpaces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsColourMultiLineStrings];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutocompleteIncludeStandardWords];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoSpellCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoGrammarCheck];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsSmartInsertDelete];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutomaticLinkDetection];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutomaticQuoteSubstitution];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsUseTabStops];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsHighlightCurrentLine];
	[dictionary setValue:[NSNumber numberWithInteger:4] forKey:MGSFragariaPrefsSpacesPerTabEntabDetab];
	
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutomaticallyIndentBraces];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoInsertAClosingParenthesis];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutoInsertAClosingBrace];
	[dictionary setValue:@"Standard" forKey:MGSFragariaPrefsSyntaxColouringPopUpString];
	
	[defaultsController setInitialValues:dictionary];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
	
	MGS_preferencesInitialized = YES;
}

/*
 
 + sharedInstance
 
 */
+ (MGSFragariaPreferences *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

/*
 
 + allocWithZone:
 
 alloc with zone for singleton
 
 */
+ (id)allocWithZone:(NSZone *)zone
{
#pragma unused(zone)
	return [self sharedInstance];
}

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init
{
    if (sharedInstance) return sharedInstance;
    self = [super init];
    if (self) {
        // load view controllers
        textEditingPrefsViewController = [[MGSFragariaTextEditingPrefsViewController alloc] init];
        fontsAndColoursPrefsViewController = [[MGSFragariaFontsAndColoursPrefsViewController alloc] init];
    }
    sharedInstance = self;
    return self;
}

/*
 
 - changeFont:
 
 */
- (void)changeFont:(id)sender
{
    /* NSFontManager will send this method up the responder chain */
    [fontsAndColoursPrefsViewController changeFont:sender];
}

/*
 
 - revertToStandardSettings:
 
 */
- (void)revertToStandardSettings:(id)sender
{
    #pragma unused(sender)
    
	[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:nil];
}
@end

