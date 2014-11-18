//
//  SMLErrorPopOver.m
//  Fragaria
//
//  Created by Viktor Lidholt on 4/11/13.
//
//

#import "SMLErrorPopOver.h"

#define kSMLErrorPopOverErrorSpacing 16

@implementation SMLErrorPopOver

+ (CGFloat) widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (void) showErrorDescriptions:(NSArray*)errors relativeToView:(NSView*) view
{
    // Add labels for each error
    int errNo = 0;
    int maxWidth = 0;
    int numErrors = (int)errors.count;
    int viewHeight = kSMLErrorPopOverErrorSpacing * numErrors;
    
    if (!numErrors) return;
    
    // Create view controller
    NSViewController* vc = [[NSViewController alloc] initWithNibName:@"ErrorPopoverView" bundle:[NSBundle bundleForClass:[self class]]];
    
    // Create labels and add them to the view
    for (NSString* err in errors)
    {
        NSTextField *textField;
        
        NSFont* font = [NSFont systemFontOfSize:10];
        
        int width = [self widthOfString:err withFont:font];
        if (width > maxWidth) maxWidth = width;
        
        textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, viewHeight - (kSMLErrorPopOverErrorSpacing * (errNo + 1)), 1024, kSMLErrorPopOverErrorSpacing)];
        [textField setStringValue:err.description];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        [textField setSelectable:NO];
        [textField setFont:font];
        
        [vc.view addSubview:textField];
        
        errNo++;
    }
    
    [vc.view setFrameSize:NSMakeSize(maxWidth, viewHeight)];
    
    // Open the popover
    NSPopover* popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = vc.view.bounds.size;
    popover.contentViewController = vc;
    popover.animates = YES;
    
    [popover showRelativeToRect:[view bounds] ofView:view preferredEdge:NSMinYEdge];
}

@end
