//
//  MGSFragariaTextEditingPrefsViewController.h
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "MGSFragariaPrefsViewController.h"

@interface MGSFragariaTextEditingPrefsViewController : MGSFragariaPrefsViewController {
    NSImage *toolbarImage;
}

- (IBAction)changeGutterWidth:(id)sender;
@end
