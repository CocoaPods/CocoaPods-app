//
//  MGSPreferencesController.h
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGSFragariaPreferences.h"
#import "DBPrefsWindowController.h"

@interface MGSPreferencesController : DBPrefsWindowController {
    IBOutlet NSView *generalView;
    MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
    MGSFragariaTextEditingPrefsViewController *textEditingPrefsViewController;
    NSString *toolbarIdentifier;
    NSString *generalIdentifier;
    NSString *textIdentifier;
    NSString *fontIdentifier;
    
}
- (IBAction)revertToStandardSettings:(id)sender;
@end
