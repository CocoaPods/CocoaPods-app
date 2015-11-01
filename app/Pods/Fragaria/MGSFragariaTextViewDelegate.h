//
//  MGSFragariaTextViewDelegate.h
//  Fragaria
//
//  Created by Jim Derry on 2/22/15.
//
//

/**
 *  This protocol defines an interface for delegates that wish
 *  to receive notifications from Fragaria's text view.
 **/
#pragma mark - MGSFragariaTextViewDelegate Protocol
@protocol MGSFragariaTextViewDelegate <NSTextViewDelegate>
@optional

/**
 * This notification is send when the paste has been accepted. You can use
 * this delegate method to query the pasteboard for additional pasteboard content
 * that may be relevant to the application: eg: a plist that may contain custom data.
 * @param note is an NSNotification instance.
 **/
- (void)mgsTextDidPaste:(NSNotification *)note;

@end


