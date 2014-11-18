//
//  MGSFragariaPrefsViewController.m
//  Fragaria
//
//  Created by Jonathan on 22/10/2012.
//
//

#import "MGSFragariaPrefsViewController.h"

@interface MGSFragariaPrefsViewController ()

@end

@implementation MGSFragariaPrefsViewController

/*
 
 - commitEditingAndDiscard:
 
 */
- (BOOL)commitEditingAndDiscard:(BOOL)discard
{
    BOOL commit = YES;
    
    // commit edits, discarding changes on error
    if (![[NSUserDefaultsController sharedUserDefaultsController] commitEditing]) {
        if (discard) [[NSUserDefaultsController sharedUserDefaultsController] discardEditing];
        commit = NO;
    }
    
    return commit;
}

#pragma mark -
#pragma mark NSTabViewDelegate

/*
 
 - tabView:shouldSelectTabViewItem:
 
 */
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
#pragma unused(tabView)
#pragma unused(tabViewItem)
    BOOL select = YES;
    
    // if we have un committed edits then disallow tab item selection
    if (![self commitEditingAndDiscard:NO]) {
        select = NO;
    }
    
    return select;
}

@end
