//
//  MGSPreferencesController.m
//  KosmicEditor
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import "MGSFragariaFramework.h"

@interface MGSPreferencesController()
- (BOOL)commitEditingAndDiscard:(BOOL)discard;
@end

@implementation MGSPreferencesController

#pragma mark -
#pragma mark Instance methods

/*
 
 -initWithWindow: is the designated initializer for NSWindowController.
 
 */
- (id)initWithWindow:(NSWindow *)window
{
#pragma unused(window)
	
    self = [super initWithWindow:window];
	if (self) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:window];

    }
	return self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
  [super dealloc];
}

/*
 
 - showWindow:
 
 */
- (void)showWindow:(id)sender
{
    // load view controllers
    textEditingPrefsViewController = [MGSFragariaPreferences sharedInstance].textEditingPrefsViewController;

    fontsAndColoursPrefsViewController = [MGSFragariaPreferences sharedInstance].fontsAndColoursPrefsViewController;

    [super showWindow:sender];
}

/*
 
 - setupToolbar
 
 */
- (void)setupToolbar
{
    generalIdentifier = NSLocalizedString(@"General", @"Preferences tab name");
    textIdentifier = NSLocalizedString(@"Text Editing", @"Preferences tab name");
    fontIdentifier = NSLocalizedString(@"Fonts & Colours", @"Preferences tab name");
    
	[self addView:generalView label:generalIdentifier];

	[self addView:textEditingPrefsViewController.view label:textIdentifier image:[NSImage imageNamed:@"General.png"]];
    
    [self addView:fontsAndColoursPrefsViewController.view label:fontIdentifier image:[NSImage imageNamed:@"General.png"]];
		
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
    [[MGSFragariaPreferences sharedInstance] revertToStandardSettings:sender];
}

/*
 
 - commitEditingAndDiscard:
 
 */
- (BOOL)commitEditingAndDiscard:(BOOL)discard
{
    BOOL commit = YES;
    
    if ([toolbarIdentifier isEqual:textIdentifier]) {
        if (![textEditingPrefsViewController commitEditingAndDiscard:discard]) {
            commit = NO;
        }
    } else if ([toolbarIdentifier isEqual:fontIdentifier]) {
        if (![fontsAndColoursPrefsViewController commitEditingAndDiscard:discard]) {
            commit = NO;
        }
        
    } else {
    
        // commit edits, discarding changes on error
        if (![[NSUserDefaultsController sharedUserDefaultsController] commitEditing]) {
            if (discard) [[NSUserDefaultsController sharedUserDefaultsController] discardEditing];
            commit = NO;
        }
    }
    
    return commit;
}

/*
 
 - windowWillClose
 
 */
- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] != [self window]) {
		return;
	}
    
    // commit editing, discard any uncommitted changes
    [self commitEditingAndDiscard:YES];
}


/*
 
 - displayViewForIdentifier:animate:
 
 */
- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate
{
    // look for uncommitted changes
    if (![self commitEditingAndDiscard:NO] && toolbarIdentifier) {
        
        // we have uncommited changes, reselect the tool bar item
        [[[self window] toolbar] setSelectedItemIdentifier:toolbarIdentifier];
    } else {
        [super displayViewForIdentifier:identifier animate:animate];
    }
    
    toolbarIdentifier = identifier;
}

@end
