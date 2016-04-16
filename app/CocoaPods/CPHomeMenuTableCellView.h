#import <Cocoa/Cocoa.h>

/// A custom table cell view that has a reference to a subtitle
/// so we can change it's colour when a cell is selected.

@interface CPHomeMenuTableCellView : NSTableCellView

@property (nullable, assign) IBOutlet NSTextField *subtitleTextField;

@end
