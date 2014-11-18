/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

// class extension
@interface MGSExtraInterfaceController()
@end

@implementation MGSExtraInterfaceController

@synthesize openPanelAccessoryView, openPanelEncodingsPopUp, commandResultWindow, commandResultTextView, projectWindow;

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init 
{
	self = [super init];
	if (self) {
	}
	
	return self;
}

#pragma mark -
#pragma mark Tabbing
/*
 
 - displayEntab
 
 */

- (void)displayEntab
{
	if (entabWindow == nil) {
		[NSBundle loadNibNamed:@"SMLEntab.nib" owner:self];
	}
	
	[NSApp beginSheet:entabWindow modalForWindow:SMLCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

/*
 
 - displayDetab
 
 */
- (void)displayDetab
{
	if (detabWindow == nil) {
		[NSBundle loadNibNamed:@"SMLDetab.nib" owner:self];
	}
	
	[NSApp beginSheet:detabWindow modalForWindow:SMLCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}


/*
 
 - entabButtonEntabWindowAction:
 
 */
- (IBAction)entabButtonEntabWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[SMLCurrentWindow attachedSheet]]; 
	[[SMLCurrentWindow attachedSheet] close];
	
	[[MGSTextMenuController sharedInstance] performEntab];
}

/*
 
 - detabButtonDetabWindowAction
 
 */
- (IBAction)detabButtonDetabWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[SMLCurrentWindow attachedSheet]]; 
	[[SMLCurrentWindow attachedSheet] close];
	
	[[MGSTextMenuController sharedInstance] performDetab];
}

#pragma mark -
#pragma mark Goto 

/*
 
 - cancelButtonEntabDetabGoToLineWindowsAction:
 
 */
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender
{
	#pragma unused(sender)
	
	NSWindow *window = SMLCurrentWindow;
	[NSApp endSheet:[window attachedSheet]]; 
	[[SMLCurrentWindow attachedSheet] close];
}


/*
 
 - displayGoToLine
 
 */
- (void)displayGoToLine
{
	if (goToLineWindow == nil) {
		[NSBundle loadNibNamed:@"SMLGoToLine.nib" owner:self];
	}
	
	[NSApp beginSheet:goToLineWindow modalForWindow:SMLCurrentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

/*
 
 - goButtonGoToLineWindowAction
 
 */
- (IBAction)goButtonGoToLineWindowAction:(id)sender
{
	#pragma unused(sender)
	
	[NSApp endSheet:[SMLCurrentWindow attachedSheet]]; 
	[[SMLCurrentWindow attachedSheet] close];
	
	[[MGSTextMenuController sharedInstance] performGoToLine:[lineTextFieldGoToLineWindow integerValue]];
}

#pragma mark -
#pragma mark Panels
/*
 
 - openPanelEncodingsPopUp
 
 */
- (NSPopUpButton *)openPanelEncodingsPopUp
{
	if (openPanelEncodingsPopUp == nil) {
		[NSBundle loadNibNamed:@"SMLOpenPanelAccessoryView.nib" owner:self];
	}
	
	return openPanelEncodingsPopUp;
}

/*
 
 - openPanelAccessoryView
 
 */
- (NSView *)openPanelAccessoryView
{
	if (openPanelAccessoryView == nil) {
		[NSBundle loadNibNamed:@"SMLOpenPanelAccessoryView.nib" owner:self];
	}
	
	return openPanelAccessoryView;
}

/*
 
 - showRegularExpressionsHelpPanel
 
 */
- (void)showRegularExpressionsHelpPanel
{
	if (regularExpressionsHelpPanel == nil) {
		[NSBundle loadNibNamed:@"SMLRegularExpressionHelp.nib" owner:self];
	}
	
	[regularExpressionsHelpPanel makeKeyAndOrderFront:nil];
}

#pragma mark -
#pragma mark Command handling

/*
 
 - commandResultWindow
 
 */
- (NSWindow *)commandResultWindow
{
    if (commandResultWindow == nil) {
		[NSBundle loadNibNamed:@"SMLCommandResult.nib" owner:self];
		[commandResultWindow setTitle:COMMAND_RESULT_WINDOW_TITLE];
	}
	
	return commandResultWindow;
}

/*
 
 - commandResultTextView
 
 */
- (NSTextView *)commandResultTextView
{
    if (commandResultTextView == nil) {
		[NSBundle loadNibNamed:@"SMLCommandResult.nib" owner:self];
		[commandResultWindow setTitle:COMMAND_RESULT_WINDOW_TITLE];		
	}
	
	return commandResultTextView; 
}

/*
 
 - showCommandResultWindow
 
 */
- (void)showCommandResultWindow
{
	[[self commandResultWindow] makeKeyAndOrderFront:nil];
}

@end
