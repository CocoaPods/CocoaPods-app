/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net

 Copyright 2004-2009 Peter Borg
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 this file except in compliance with the License. You may obtain a copy of the
 License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for the
 specific language governing permissions and limitations under the License.
*/

#import <Cocoa/Cocoa.h>


@class SMLTextView;


/** MGSExtraInterfaceController displays and controls the NSPanels and the
 *  NSMenus used by SMLTextView's methods which require an interaction with
 *  the user. */

@interface MGSExtraInterfaceController : NSObject {
	IBOutlet NSTextField *spacesTextFieldEntabWindow;
	IBOutlet NSTextField *spacesTextFieldDetabWindow;
	IBOutlet NSTextField *lineTextFieldGoToLineWindow;
	IBOutlet NSWindow *entabWindow;
	IBOutlet NSWindow *detabWindow;
	IBOutlet NSWindow *goToLineWindow;
}


/// @name Action Methods


/** Action sent by the entab button in the entab window.
 *  @param sender Object sending the action. */
- (IBAction)entabButtonEntabWindowAction:(id)sender;
/** Action sent by the detab button in the detab window.
 *  @param sender Object sending the action. */
- (IBAction)detabButtonDetabWindowAction:(id)sender;
/** Action sent by the goto button in the goto window.
 *  @param sender Object sending the action. */
- (IBAction)goButtonGoToLineWindowAction:(id)sender;

/** Action sent by the cancel button in the entab, detab, and goto windows.
 *  @param sender Object sending the action. */
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender;


/// @name Accessing the user interface


/** A context menu for use by SMLTextView. */
@property (nonatomic) IBOutlet NSMenu *contextMenu;

/** Displays the entab sheet.
 *  @param target The text view to send a performEntab message to if the user
 *                confirmed the action. */
- (void)displayEntabForTarget:(SMLTextView *)target;

/** Displays the detab sheet.
 *  @param target The text view to send a performDetab message to if the user
 *                confirmed the action. */
- (void)displayDetabForTarget:(SMLTextView *)target;

/** Displays the go to line sheet.
 *  @param target The text view to send a performGoToLine:setSelected: message
 *                to if the user confirmed the action. */
- (void)displayGoToLineForTarget:(SMLTextView *)target;                                             


@end
