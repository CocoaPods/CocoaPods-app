/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 this file except in compliance with the License. You may obtain a copy of the
 License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for the
 specific language governing permissions and limitations under the License.
*/

#import "MGSExtraInterfaceController.h"
#import "SMLTextView+MGSTextActions.h"


@implementation MGSExtraInterfaceController {
    SMLTextView *_completionTarget;
}


- (NSMenu*)contextMenu
{
    if (!_contextMenu)
        [NSBundle loadNibNamed:@"MGSContextMenu" owner:self];
    return _contextMenu;
}


#pragma mark -
#pragma mark Tabbing


/*
 * - displayEntab
 */
- (void)displayEntabForTarget:(SMLTextView *)target
{
    NSWindow *wnd;
    
	if (entabWindow == nil) {
		[NSBundle loadNibNamed:@"SMLEntab.nib" owner:self];
        spacesTextFieldEntabWindow.integerValue = target.tabWidth;
	}
	
    _completionTarget = target;
    wnd = [_completionTarget window];
	[NSApp beginSheet:entabWindow modalForWindow:wnd modalDelegate:self didEndSelector:nil contextInfo:nil];
}


/*
 * - displayDetab
 */
- (void)displayDetabForTarget:(SMLTextView *)target
{
    NSWindow *wnd;
    
	if (detabWindow == nil) {
		[NSBundle loadNibNamed:@"SMLDetab.nib" owner:self];
        spacesTextFieldDetabWindow.integerValue = target.tabWidth;
	}
	
    _completionTarget = target;
    wnd = [_completionTarget window];
	[NSApp beginSheet:detabWindow modalForWindow:wnd modalDelegate:self didEndSelector:nil contextInfo:nil];
}


/*
 * - entabButtonEntabWindowAction:
 */
- (IBAction)entabButtonEntabWindowAction:(id)sender
{
	NSWindow *wnd = [_completionTarget window];
	
	[NSApp endSheet:[wnd attachedSheet]];
	[[wnd attachedSheet] close];
	
    [_completionTarget performEntabWithNumberOfSpaces:[spacesTextFieldEntabWindow integerValue]];
    _completionTarget = nil;
}


/*
 * - detabButtonDetabWindowAction
 */
- (IBAction)detabButtonDetabWindowAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];
    
    [NSApp endSheet:[wnd attachedSheet]];
    [[wnd attachedSheet] close];
	
	[_completionTarget performDetabWithNumberOfSpaces:[spacesTextFieldDetabWindow integerValue]];
    _completionTarget = nil;
}


#pragma mark -
#pragma mark Goto 


/*
 * - cancelButtonEntabDetabGoToLineWindowsAction:
 */
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];
    
    [NSApp endSheet:[wnd attachedSheet]];
    [[wnd attachedSheet] close];
    _completionTarget = nil;
}


/*
 * - displayGoToLine
 */
- (void)displayGoToLineForTarget:(SMLTextView *)target
{
    _completionTarget = target;
    NSWindow *wnd = [_completionTarget window];
    
	if (goToLineWindow == nil) {
		[NSBundle loadNibNamed:@"SMLGoToLine.nib" owner:self];
	}
	
	[NSApp beginSheet:goToLineWindow modalForWindow:wnd modalDelegate:self didEndSelector:nil contextInfo:nil];
}


/*
 * - goButtonGoToLineWindowAction
 */
- (IBAction)goButtonGoToLineWindowAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];
    
    [NSApp endSheet:[wnd attachedSheet]];
    [[wnd attachedSheet] close];
	
	[_completionTarget performGoToLine:[lineTextFieldGoToLineWindow integerValue] setSelected:YES];
    _completionTarget = nil;
}


@end
