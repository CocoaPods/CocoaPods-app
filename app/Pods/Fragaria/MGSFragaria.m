//
//  MGSFragaria.m
//  Fragaria
//
//  Created by Jonathan on 05/05/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//
#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"
#import "FRAFontTransformer.h"

// valid keys for 
// - (void)setObject:(id)object forKey:(id)key;
// - (id)objectForKey:(id)key;

// BOOL
NSString * const MGSFOIsSyntaxColoured = @"isSyntaxColoured";
NSString * const MGSFOShowLineNumberGutter = @"showLineNumberGutter";
NSString * const MGSFOIsEdited = @"isEdited";
NSString * const MGSFOHasVerticalScroller = @"hasVerticalScroller";
NSString * const MGSFODisableScrollElasticity = @"disableScrollElasticity";

// string
NSString * const MGSFOSyntaxDefinitionName = @"syntaxDefinition";
NSString * const MGSFODocumentName = @"name";

// class name strings
// TODO: expose these to allow subclass name definition
NSString * const MGSFOEditorTextViewClassName = @"editorTextViewClassName";
NSString * const MGSFOLineNumbersClassName = @"lineNumbersClassName";
NSString * const MGSFOGutterTextViewClassName = @"gutterTextViewClassName";
NSString * const MGSFOSyntaxColouringClassName = @"syntaxColouringClassName";

// integer
NSString * const MGSFOGutterWidth = @"gutterWidth";

// NSView *
NSString * const ro_MGSFOTextView = @"firstTextView"; // readonly
NSString * const ro_MGSFOScrollView = @"firstTextScrollView"; // readonly
NSString * const ro_MGSFOGutterScrollView = @"firstGutterScrollView"; // readonly

// NSObject
NSString * const MGSFODelegate = @"delegate";
NSString * const MGSFOBreakpointDelegate = @"breakpointDelegate";
NSString * const MGSFOAutoCompleteDelegate = @"autoCompleteDelegate";
NSString * const MGSFOSyntaxColouringDelegate = @"syntaxColouringDelegate";
NSString * const ro_MGSFOLineNumbers = @"lineNumbers"; // readonly
NSString * const ro_MGSFOSyntaxColouring = @"syntaxColouring"; // readonly

static MGSFragaria *_currentInstance;

// KVO context constants
char kcGutterWidthPrefChanged;
char kcSyntaxColourPrefChanged;
char kcSpellCheckPrefChanged;
char kcLineNumberPrefChanged;
char kcLineWrapPrefChanged;

// class extension
@interface MGSFragaria()
@property (nonatomic, readwrite) MGSExtraInterfaceController *extraInterfaceController;

- (void)updateGutterView;

@property (nonatomic,strong) NSSet* objectGetterKeys;
@property (nonatomic,strong) NSSet* objectSetterKeys;

@end

@implementation MGSFragaria

@synthesize extraInterfaceController;
@synthesize docSpec;
@synthesize objectSetterKeys;
@synthesize objectGetterKeys;

#pragma mark -
#pragma mark Class methods

/*
 
 + currentInstance;
 
 */
+ (id)currentInstance
{
	/*
	 
	 We need to have access to the current instance.
	 This is used by the various singleton controllers to provide a target for their actions.
	 
	 The instance in the key window will automatically be assigned as the current instance.
	 
	 */
	return _currentInstance;
}

/*
 
 + currentInstance;
 
 */
+ (void)setCurrentInstance:(MGSFragaria *)anInstance
{
	NSAssert([anInstance isKindOfClass:[self class]], @"bad class");
	_currentInstance = anInstance;
}


/*
 
 + initialize
 
 */
+ (void)initialize
{
	[MGSFragariaPreferences initializeValues];
}

/*
 
 + initializeFramework
 
 */
+ (void)initializeFramework
{
	// + initialize does the work
}

/*
 
 + createDocSpec
 
 */
+ (id)createDocSpec
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // initialise document spec from user defaults
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], MGSFOHasVerticalScroller,
            [NSNumber numberWithBool:NO], MGSFODisableScrollElasticity,
            @"Standard", MGSFOSyntaxDefinitionName,
            [defaults objectForKey:MGSFragariaPrefsSyntaxColourNewDocuments], MGSFOIsSyntaxColoured,
            [defaults objectForKey:MGSFragariaPrefsShowLineNumberGutter], MGSFOShowLineNumberGutter,
            [defaults objectForKey:MGSFragariaPrefsGutterWidth], MGSFOGutterWidth,
			nil];
}

/*
 
 + docSpec:setString:
 
 */
+ (void)docSpec:(id)docSpec setString:(NSString *)string
{
	// set text view string
	[[docSpec valueForKey:ro_MGSFOTextView] setString:string];
}

/*
 
 + docSpec:setString:options:
 
 */
+ (void)docSpec:(id)docSpec setString:(NSString *)string options:(NSDictionary *)options
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setString:string options:options];
}

/*
 
 + docSpec:setAttributedString
 
 */
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string 
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setAttributedString:string];
}

/*
 
 + docSpec:setAttributedString:options:
 
 */
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string options:(NSDictionary *)options
{
	// set text view string
	[(SMLTextView *)[docSpec valueForKey:ro_MGSFOTextView] setAttributedString:string options:options];
}

/*
 
 + stringForDocSpec:
 
 */
+ (NSString *)stringForDocSpec:(id)docSpec
{
	return [[docSpec valueForKey:ro_MGSFOTextView] string];
}

/*
 
 + attributedStringForDocSpec:
 
 */
+ (NSAttributedString *)attributedStringForDocSpec:(id)docSpec
{
	return [[[docSpec valueForKey:ro_MGSFOTextView] layoutManager] attributedString];
}

/*
 
 + attributedStringWithTemporaryAttributesAppliedForDocSpec:
 
 */
+ (NSAttributedString *)attributedStringWithTemporaryAttributesAppliedForDocSpec:(id)docSpec
{
	// recolour the entire textview content
	SMLTextView *textView = [docSpec valueForKey:ro_MGSFOTextView];
	SMLSyntaxColouring *syntaxColouring = [docSpec valueForKey:ro_MGSFOSyntaxColouring];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"colourAll", nil];
	[syntaxColouring pageRecolourTextView:textView options: options];
	
	// get content with layout manager temporary attributes persisted
	SMLLayoutManager *layoutManager = (SMLLayoutManager *)[textView layoutManager];
	return [layoutManager attributedStringWithTemporaryAttributesApplied];
}

#pragma mark -
#pragma mark Instance methods
/*
 
 - initWithObject
 
 Designated initializer
 
 Calling this method enables us to use a predefined object
 for our doc spec.
 eg: Smultron used a CoreData object.
 
 */
- (id)initWithObject:(id)object
{
	if ((self = [super init])) {
		_currentInstance = self;
		
        // a doc spec is mandatory
		if (object) {
			self.docSpec = object;
		} else {
			self.docSpec = [[self class] createDocSpec];
		}
        
        _startingLineNumber = 0;
        
        // register the font transformer
        FRAFontTransformer *fontTransformer = [[FRAFontTransformer alloc] init];
        [NSValueTransformer setValueTransformer:fontTransformer forName:@"FontTransformer"];
        
        // observe defaults that affect rendering
        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaGutterWidth" options:NSKeyValueObservingOptionNew context:&kcGutterWidthPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaSyntaxColourNewDocuments" options:NSKeyValueObservingOptionNew context:&kcSyntaxColourPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaAutoSpellCheck" options:NSKeyValueObservingOptionNew context:&kcSpellCheckPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaShowLineNumberGutter" options:NSKeyValueObservingOptionNew context:&kcLineNumberPrefChanged];
        [defaultsController addObserver:self forKeyPath:@"values.FragariaLineWrapNewDocuments" options:NSKeyValueObservingOptionNew context:&kcLineWrapPrefChanged];
        
        // Create the Sets containing the valid setter/getter combinations for the Docspec
        
        // Define read/write keys
        self.objectSetterKeys = [NSSet setWithObjects:MGSFOIsSyntaxColoured, MGSFOShowLineNumberGutter, MGSFOIsEdited,
                            MGSFOHasVerticalScroller, MGSFODisableScrollElasticity, MGSFODocumentName,
                            MGSFOSyntaxDefinitionName, MGSFODelegate, MGSFOBreakpointDelegate, MGSFOAutoCompleteDelegate, MGSFOSyntaxColouringDelegate,
                            nil];
        
        // Define read only keys
        self.objectGetterKeys = [NSMutableSet setWithObjects:ro_MGSFOTextView, ro_MGSFOScrollView, ro_MGSFOGutterScrollView,
                            ro_MGSFOLineNumbers, ro_MGSFOSyntaxColouring,
                            nil];
        
        // Merge both to get all getters
        [(NSMutableSet *)self.objectGetterKeys unionSet:self.objectSetterKeys];
	}

	return self;
}

/*
 
 - init
 
 */
- (id)init
{
	return [self initWithObject:nil];
}


#pragma mark View handling
/*
 
 - embedInView:
 
 */
- (void)embedInView:(NSView *)contentView
{
    NSAssert(contentView != nil, @"A content view must be provided.");
    
	NSInteger gutterWidth = [[SMLDefaults valueForKey:MGSFragariaPrefsGutterWidth] integerValue];
    
    // TODO: allow user to pass in custom class name in doc spec. This will likely entail refactoring
    // the relevant clas headers to exposure sufficient information to make subclassing feasible.
    Class editorTextViewClass = [SMLTextView class];
    Class lineNumberClass = [SMLLineNumbers class];
    Class gutterTextViewClass = [SMLGutterTextView class];
    Class syntaxColouringClass = [SMLSyntaxColouring class];
    
	// create text scrollview
	NSScrollView *textScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, [contentView bounds].size.width, [contentView bounds].size.height)];
	NSSize contentSize = [textScrollView contentSize];
	[textScrollView setBorderType:NSNoBorder];
    if (self.hasVerticalScroller) {
        [textScrollView setHasVerticalScroller:YES];
        [textScrollView setAutohidesScrollers:YES];
	} else {
        [textScrollView setHasVerticalScroller:NO];
        [textScrollView setAutohidesScrollers:NO];
    }
    if (self.isScrollElasticityDisabled) {
        [textScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    } else {
        [textScrollView setVerticalScrollElasticity:NSScrollElasticityAutomatic];
    }
	[textScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[textScrollView contentView] setAutoresizesSubviews:YES];
	[textScrollView setPostsFrameChangedNotifications:YES];
		
	// create textview
	SMLTextView *textView = [[editorTextViewClass alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [textView setFragaria:self];
	[textScrollView setDocumentView:textView];

    // create line numbers
	SMLLineNumbers *lineNumbers = [[lineNumberClass alloc] initWithDocument:self.docSpec];
    [lineNumbers setStartingLineNumber: _startingLineNumber];
	[self.docSpec setValue:lineNumbers forKey:ro_MGSFOLineNumbers];

    // SMLLineNumbers will be notified of changes to the text scroll view content view due to scrolling
    [[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[textScrollView contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:lineNumbers selector:@selector(viewBoundsDidChange:) name:NSViewFrameDidChangeNotification object:[textScrollView contentView]];
    
    //// Will be unregistered in SMLLineNumbers dealloc
    

	// create gutter scrollview
	NSScrollView *gutterScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height)];
	[gutterScrollView setBorderType:NSNoBorder];
	[gutterScrollView setHasVerticalScroller:NO];
	[gutterScrollView setHasHorizontalScroller:NO];
    if (self.isScrollElasticityDisabled) {
        [gutterScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    } else {
        [gutterScrollView setVerticalScrollElasticity:NSScrollElasticityAutomatic];
    }
	[gutterScrollView setAutoresizingMask:NSViewHeightSizable];
	[[gutterScrollView contentView] setAutoresizesSubviews:YES];
	
	// create gutter textview
	SMLGutterTextView *gutterTextView = [[gutterTextViewClass alloc] initWithFrame:NSMakeRect(0, 0, gutterWidth, contentSize.height - 50)];
	[gutterScrollView setDocumentView:gutterTextView];
	
	// update the docSpec
	[self.docSpec setValue:textView forKey:ro_MGSFOTextView];
	[self.docSpec setValue:textScrollView forKey:ro_MGSFOScrollView];
	[self.docSpec setValue:gutterScrollView forKey:ro_MGSFOGutterScrollView];
	
	// add syntax colouring
	SMLSyntaxColouring *syntaxColouring = [[syntaxColouringClass alloc] initWithDocument:self.docSpec];
	[self.docSpec setValue:syntaxColouring forKey:ro_MGSFOSyntaxColouring];
	[self.docSpec setValue:syntaxColouring forKey:MGSFOAutoCompleteDelegate];
    
	// add scroll view to content view
	[contentView addSubview:[self.docSpec valueForKey:ro_MGSFOScrollView]];
	
	// update line numbers
	[[self.docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersForClipView:[[self.docSpec valueForKey:ro_MGSFOScrollView] contentView] checkWidth:NO recolour:YES];
    
    // update the gutter view
    [self updateGutterView];
    
    // apply default line wrapping
    [textView updateLineWrap];
    [textView setLineWrap:[[SMLDefaults valueForKey:MGSFragariaPrefsLineWrapNewDocuments] boolValue]];

}


/*
 
 - goToLine:centered:
 
 */
- (void)goToLine:(NSInteger)lineToGoTo centered:(BOOL)centered highlight:(BOOL)highlight
{
	NSInteger lineNumber;
	NSInteger idx;
	NSString *completeString = self.textView.string;
	NSInteger completeStringLength = [completeString length];
	NSInteger numberOfLinesInDocument;
	for (idx = 0, numberOfLinesInDocument = 1; idx < completeStringLength; numberOfLinesInDocument++) {
		idx = NSMaxRange([completeString lineRangeForRange:NSMakeRange(idx, 0)]);
	}
	if (lineToGoTo > numberOfLinesInDocument) {
		NSBeep();
		return;
	}
	
	for (idx = 0, lineNumber = 1; lineNumber < lineToGoTo; lineNumber++) {
		idx = NSMaxRange([completeString lineRangeForRange:NSMakeRange(idx, 0)]);
	}
    
	NSInteger idxStart = 0;
	NSInteger idxEnd = 0;
    if (centered) {
        // get the number of visible lines, since we always show line numbers, just re-use that calculations
        id document = self.docSpec;
        SMLLineNumbers *lineNumbers = (SMLLineNumbers *)[document valueForKey:ro_MGSFOLineNumbers];
        
        NSInteger numberOfVisibleLines = [lineNumbers numberOfVisibleLines];
        
        if (numberOfVisibleLines > 0) {
            NSInteger startLine = 0;
            NSInteger endLine = 0;
            NSInteger visibleLinesByHalf = 0;
            if (numberOfVisibleLines > 1) {
                visibleLinesByHalf = (numberOfVisibleLines-1) / 2;
            }
            
            if (lineToGoTo > visibleLinesByHalf) {
                startLine = lineToGoTo - visibleLinesByHalf;
            } else {
                startLine = 0;
            }
            
            endLine = startLine + numberOfVisibleLines;
            if (endLine > numberOfLinesInDocument) {
                endLine = numberOfLinesInDocument;
                startLine = numberOfLinesInDocument - numberOfVisibleLines;
                if (startLine < 0)
                    startLine = 0;
            }

            for (idxStart = 0, lineNumber = 1; lineNumber < startLine; lineNumber++) {
                idxStart = NSMaxRange([completeString lineRangeForRange:NSMakeRange(idxStart, 0)]);
            }
            
            for (idxEnd = idxStart, lineNumber = startLine; lineNumber < endLine; lineNumber++) {
                idxEnd = NSMaxRange([completeString lineRangeForRange:NSMakeRange(idxEnd, 0)]);
            }
            idxEnd -= idxStart;
        } else {
            idxStart = idx;
        }
    } else {
        idxStart = idx;
    }
    
    if (highlight) {
        [self.textView setSelectedRange:[completeString lineRangeForRange:NSMakeRange(idx, 0)]];
    }
	[self.textView scrollRangeToVisible:[completeString lineRangeForRange:NSMakeRange(idxStart, idxEnd)]];
}


#pragma mark -
#pragma mark Document specification



/*
 
 - setObject:forKey:
 
 */
- (void)setObject:(id)object forKey:(id)key
{
	if ([self.objectSetterKeys containsObject:key]) {
		[(id)self.docSpec setValue:object forKey:key];
	}
}

/*
 
 - objectForKey:
 
 */
- (id)objectForKey:(id)key
{
	if ([self.objectGetterKeys containsObject:key]) {
		return [self.docSpec valueForKey:key];
	}
	
	return nil;
}


#pragma mark -
#pragma mark Accessors

/*
 
 - setString:
 
 */
- (void)setString:(NSString *)aString
{
	[[self class] docSpec:self.docSpec setString:aString];
}

/*
 
 - setString:options:
 
 */
- (void)setString:(NSString *)aString options:(NSDictionary *)options
{
	[[self class] docSpec:self.docSpec setString:aString options:options];
}

/*
 
 - setAttributedString:
 
 */
- (void)setAttributedString:(NSAttributedString *)aString 
{
	[[self class] docSpec:self.docSpec setAttributedString:aString];
}

/*
 
 - setAttributedString:options:
 
 */
- (void)setAttributedString:(NSAttributedString *)aString options:(NSDictionary *)options
{
	[[self class] docSpec:self.docSpec setAttributedString:aString options:options];
}


/*
 
 - attributedString
 
 */
- (NSAttributedString *)attributedString
{
	return [[self class] attributedStringForDocSpec:self.docSpec];
}

/*
 
 - attributedStringWithTemporaryAttributesApplied
 
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
	return [[self class] attributedStringWithTemporaryAttributesAppliedForDocSpec:self.docSpec];
}

/*
 
 - attributedString
 
 */
- (NSString *)string
{
	return [[self class] stringForDocSpec:self.docSpec];
}

/*
 
 - textView
 
 */
- (NSTextView *)textView
{
	return [self objectForKey:ro_MGSFOTextView];
}

/*
 
 - setSyntaxDefinitionName:
 
 */
- (void)setSyntaxDefinitionName:(NSString *)value
{
    [self setObject:value forKey:MGSFOSyntaxDefinitionName];
}
/*
 
 - syntaxDefinitionName
 
 */
- (NSString *)syntaxDefinitionName
{
    return [self objectForKey:MGSFOSyntaxDefinitionName];
}

/*
 
 - setDocumentName:
 
 */
- (void)setDocumentName:(NSString *)value
{
    [self setObject:value forKey:MGSFODocumentName];
}
/*
 
 - documentName
 
 */
- (NSString *)documentName
{
    return [self objectForKey:MGSFODocumentName];
}

/*
 
 - setStartingLineNumber:
 
 */
- (void)setStartingLineNumber:(NSUInteger)value
{
    _startingLineNumber = value;
    [self updateGutterView];
}
/*
 
 - startingLineNumber
 
 */
- (NSUInteger)startingLineNumber
{
    return _startingLineNumber;
}

/*
 
 - setDisableScrollElasticity:
 
 */
- (void)setDisableScrollElasticity:(BOOL)value
{
    [self setObject:[NSNumber numberWithBool:value] forKey:MGSFODisableScrollElasticity];
    [self updateGutterView];
}
/*
 
 - isScrollElasticityDisabled
 
 */
- (BOOL)isScrollElasticityDisabled
{
    NSNumber *value = [self objectForKey:MGSFODisableScrollElasticity];
    return [value boolValue];
}

/*
 
 - setHasVerticalScroller:
 
 */
- (void)setHasVerticalScroller:(BOOL)value
{
  [self setObject:[NSNumber numberWithBool:value] forKey:MGSFOHasVerticalScroller];
  [self updateGutterView];
}
/*
 
 - hasVerticalScroller
 
 */
- (BOOL)hasVerticalScroller
{
  NSNumber *value = [self objectForKey:MGSFOHasVerticalScroller];
  return [value boolValue];
}

/*
 
 - setShowsLineNumbers:
 
 */
- (void)setShowsLineNumbers:(BOOL)value
{
    [self setObject:[NSNumber numberWithBool:value] forKey:MGSFOShowLineNumberGutter];
    [self updateGutterView];
}
/*
 
 - showsLineNumbers
 
 */
- (BOOL)showsLineNumbers
{
    NSNumber *value = [self objectForKey:MGSFOShowLineNumberGutter];
    return [value boolValue];
}
/*
 
 - setSyntaxColoured
 
 */
- (void)setSyntaxColoured:(BOOL)value
{
    [self setObject:[NSNumber numberWithBool:value] forKey:MGSFOIsSyntaxColoured]; 
    [self reloadString];
}
/*
 
 - isSyntaxColoured
 
 */
- (BOOL)isSyntaxColoured
{
    NSNumber *value = [self objectForKey:MGSFOIsSyntaxColoured];
    return [value boolValue];
}

/*
 
 - reloadString
 
 */
- (void)reloadString
{
    [self setString:[self string]];
}

/*
 
 - setSyntaxErrors:
 
 */
- (void)setSyntaxErrors:(NSArray *)errors
{
    SMLSyntaxColouring *syntaxColouring = [docSpec valueForKey:ro_MGSFOSyntaxColouring];
    syntaxColouring.syntaxErrors = errors;
    [syntaxColouring pageRecolour];
}

/*
 
 - syntaxErrors
 
 */
- (NSArray *)syntaxErrors
{
    SMLSyntaxColouring *syntaxColouring = [docSpec valueForKey:ro_MGSFOSyntaxColouring];
    return syntaxColouring.syntaxErrors;
}

#pragma mark -
#pragma mark Controllers

/*
 
 - textMenuController
 
 */
- (MGSTextMenuController *)textMenuController
{
	return [MGSTextMenuController sharedInstance];
}

/*
 
 - extraInterfaceController
 
 */
- (MGSExtraInterfaceController *)extraInterfaceController
{
	if (!extraInterfaceController) {
		extraInterfaceController = [[MGSExtraInterfaceController alloc] init];
	}
	
	return extraInterfaceController;
}

#pragma mark -
#pragma mark KVO
/*
 
 - observeValueForKeyPath:ofObject:change:context:
 
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL boolValue = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if (context == &kcGutterWidthPrefChanged) {

        [self updateGutterView];

    } else if (context == &kcLineNumberPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsShowLineNumberGutter];
        [self setShowsLineNumbers:boolValue];
        
    } else if (context == &kcSyntaxColourPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsSyntaxColourNewDocuments];
        [self setSyntaxColoured:boolValue];
        
    } else if (context == &kcSpellCheckPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsAutoSpellCheck];
        [[self textView] setContinuousSpellCheckingEnabled:boolValue];
        
    } else if (context == &kcLineWrapPrefChanged) {
        
        boolValue = [defaults boolForKey:MGSFragariaPrefsLineWrapNewDocuments];
        [(SMLTextView *)[self textView] setLineWrap:boolValue];
        [[self.docSpec valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
    } else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
}

#pragma mark -
#pragma mark Class extension
/*
 
 - updateGutterView
 
 */
- (void) updateGutterView {
    id document = self.docSpec;

    BOOL hasVerticalScroller = [[self.docSpec valueForKey:MGSFOHasVerticalScroller] boolValue];
    BOOL isScrollElasticityDisabled = [[self.docSpec valueForKey:MGSFODisableScrollElasticity] boolValue];

    BOOL showGutter = [[self.docSpec valueForKey:MGSFOShowLineNumberGutter] boolValue];
	NSUInteger gutterWidth = [[SMLDefaults valueForKey:MGSFragariaPrefsGutterWidth] integerValue];
    NSUInteger gutterOffset = (showGutter ? gutterWidth : 0);
	NSRect frame, newFrame;
	
	// Update document value first.
	[document setValue:[NSNumber numberWithUnsignedInteger:gutterWidth] forKey:MGSFOGutterWidth];
	
    // get editor views
    NSScrollView *textScrollView = (NSScrollView *)[document valueForKey:ro_MGSFOScrollView];
    NSScrollView *gutterScrollView = (NSScrollView *) [document valueForKey:ro_MGSFOGutterScrollView];
    NSTextView *textView = (NSTextView *)[document valueForKey:ro_MGSFOTextView];
    
    // update scroller
    if (hasVerticalScroller) {
        [textScrollView setHasVerticalScroller:YES];
        [textScrollView setAutohidesScrollers:YES];
    } else {
        [textScrollView setHasVerticalScroller:NO];
        [textScrollView setAutohidesScrollers:NO];
    }
    if (isScrollElasticityDisabled) {
        [textScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
        [gutterScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    } else {
        [textScrollView setVerticalScrollElasticity:NSScrollElasticityAutomatic];
        [gutterScrollView setVerticalScrollElasticity:NSScrollElasticityAutomatic];
    }
    
    // get line numbers
    SMLLineNumbers *lineNumbers = (SMLLineNumbers *)[document valueForKey:ro_MGSFOLineNumbers];
    [lineNumbers setStartingLineNumber: _startingLineNumber];
    
    // get content view
    NSView *contentView = [textScrollView superview];
    CGFloat contentWidth = [contentView bounds].size.width;
    
    // Text Scroll View
    if (textScrollView != nil) {
        frame = [textScrollView frame];
        newFrame = NSMakeRect(gutterOffset, frame.origin.y, contentWidth - gutterOffset, frame.size.height);
        [textScrollView setFrame:newFrame];
        [textScrollView setNeedsDisplay:YES];
    }
    
    // Text View
    else if (textView != nil) {
        frame = [textScrollView frame];
        newFrame = NSMakeRect(gutterOffset, frame.origin.y, contentWidth - gutterOffset, frame.size.height);
        [textView setFrame:newFrame];
        [textView setNeedsDisplay:YES];
    }
    
    // Gutter Scroll View
    if (gutterScrollView != nil) {
        frame = [gutterScrollView frame];
        newFrame = NSMakeRect(frame.origin.x, frame.origin.y, gutterWidth, frame.size.height);
        [gutterScrollView setFrame:newFrame];

        // add or remove the gutter sub view
        if (showGutter) {
            [contentView addSubview:gutterScrollView];
            [gutterScrollView setNeedsDisplay:YES];
        } else {
            [gutterScrollView removeFromSuperview];
        }
    }
    
    // update the line numbers
    [[document valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
}

#pragma mark -
#pragma mark Resource loading

+ (NSImage *) imageNamed:(NSString *)name
{
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *path = [bundle pathForImageResource:name];
    return path != nil ? [[NSImage alloc]
                           initWithContentsOfFile:path] : nil;
}

@end
