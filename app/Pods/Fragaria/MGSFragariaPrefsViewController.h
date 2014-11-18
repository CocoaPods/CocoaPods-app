//
//  MGSFragariaPrefsViewController.h
//  Fragaria
//
//  Created by Jonathan on 22/10/2012.
//
//

#import <Cocoa/Cocoa.h>

@interface MGSFragariaPrefsViewController : NSViewController <NSTabViewDelegate>
- (BOOL)commitEditingAndDiscard:(BOOL)discard;
@end
