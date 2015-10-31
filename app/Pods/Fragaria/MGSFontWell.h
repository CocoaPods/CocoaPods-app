//
//  MGSFontWell.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 27/05/15.
//
//

#import <Cocoa/Cocoa.h>


/**
 *  The MGSFontWell control is a text field which object value is a font and
 *  can be first responder, which works similarly to NSColorWell. Its text is
 *  fixed to a description of its font value. The action of this control
 *  is changing its font.
 */

@interface MGSFontWell : NSControl


/** The font object for this control */
@property (nonatomic) NSFont *font;

/** Sets the value of the receiver to a font value obtained from the specified
 *  object. 
 *  @param sender The object from which to take the value. This object must
 *                respond to the -font message.*/
- (IBAction)takeFontFrom:(id)sender;

/** Make the control first responder and order front the font panel.
 *  @param sender The object who sent the message. */
- (IBAction)activate:(id)sender;


@end
