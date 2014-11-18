//
//  MGSFragariaFontsAndColoursPrefsViewController.m
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

@interface MGSFragariaFontsAndColoursPrefsViewController ()

@end

@implementation MGSFragariaFontsAndColoursPrefsViewController

/*
 
 - init
 
 */
- (id)init {
    self = [super initWithNibName:@"MGSPreferencesFontsAndColours" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        
    }
    return self;
}

/*
 
 - setFontAction:
 
 */
- (IBAction)setFontAction:(id)sender
{
#pragma unused(sender)
    
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSData *fontData = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:MGSFragariaPrefsTextFont];
    NSFont *font = [NSUnarchiver unarchiveObjectWithData:fontData];
	[fontManager setSelectedFont:font isMultiple:NO];
	[fontManager orderFrontFontPanel:nil];
    
}

/*
 
 - changeFont:
 
 */
- (void)changeFont:(id)sender
{
    
    /* changeFont: is sent up the responder chain by the fontManager so we have to call this
     method from say the preferences window controller which has been configured as the window delegate */
	NSFontManager *fontManager = sender;
	NSFont *panelFont = [fontManager convertFont:[fontManager selectedFont]];
	[SMLDefaults setValue:[NSArchiver archivedDataWithRootObject:panelFont] forKey:MGSFragariaPrefsTextFont];
}
@end
