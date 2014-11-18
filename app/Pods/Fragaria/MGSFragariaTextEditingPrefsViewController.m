//
//  MGSFragariaTextEditingPrefsViewController.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "MGSFragariaTextEditingPrefsViewController.h"
#import "MGSFragariaFramework.h"

@interface MGSFragariaTextEditingPrefsViewController ()

@end

@implementation MGSFragariaTextEditingPrefsViewController

/*
 
 - init
 
 */
- (id)init {
    self = [super initWithNibName:@"MGSPreferencesTextEditing" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {

    }
    return self;
}

/*
 
 - changeGutterWidth:
 
 */
- (IBAction)changeGutterWidth:(id)sender {
#pragma unused(sender)
    
	/*NSEnumerator *documentEnumerator =  [[[FRACurrentProject documentsArrayController] arrangedObjects] objectEnumerator];
	for (id document in documentEnumerator) {
		[FRAInterface updateGutterViewForDocument:document];
		[[document valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
	}*/
}


@end
