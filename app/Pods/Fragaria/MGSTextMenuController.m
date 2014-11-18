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
@interface MGSTextMenuController()
- (void)setEdited:(BOOL)aBool;
- (void)reloadText:(id)sender;
- (void)performUndoChangeEncoding:(id)sender;
- (void)performUndoChangeLineEndings:(id)sender;
@end

@implementation MGSTextMenuController

static id sharedInstance = nil;

#pragma mark -
#pragma mark Class methods

/*
 
 + sharedInstance
 
 */
+ (MGSTextMenuController *)sharedInstance
{ 
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
} 

/*
 
 + allocWithZone:
 
 alloc with zone for singleton
 
 */
+ (id)allocWithZone:(NSZone *)zone
{
#pragma unused(zone)
	return [self sharedInstance];
} 

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init 
{
    if (sharedInstance == nil) {
        sharedInstance = [super init];
		
    }
    return sharedInstance;
}

/*
 
 - setEdited:
 
 */
- (void)setEdited:(BOOL)aBool
{
	if ([[SMLCurrentDocument valueForKey:MGSFOIsEdited] boolValue] != aBool) {			
		[[MGSFragaria currentInstance] setObject:[NSNumber numberWithBool:aBool] forKey:MGSFOIsEdited];
	}
}

#pragma mark -
#pragma mark NSCopying

/*
 
 - copyWithZone:
 
 copy with zone for singleton
 
 */
- (id)copyWithZone:(NSZone *)zone
{
#pragma unused(zone)
    return self;
}

#pragma mark -
#pragma mark Menu handling

/*
 
 - buildEncodingsMenus
 
 */
- (void)buildEncodingsMenus
{
	[SMLBasic removeAllItemsFromMenu:textEncodingMenu];
	[SMLBasic removeAllItemsFromMenu:reloadTextWithEncodingMenu];
	
	NSArray *encodingsArray = [SMLBasic fetchAll:@"EncodingSortKeyName"];
	NSEnumerator *enumerator = [encodingsArray reverseObjectEnumerator];
	id item;
	NSMenuItem *menuItem;
	for (item in enumerator) {
		if ([[item valueForKey:@"active"] boolValue] == YES) {
			NSUInteger encoding = [[item valueForKey:@"encoding"] unsignedIntegerValue];
			menuItem = [[NSMenuItem alloc] initWithTitle:[NSString localizedNameOfStringEncoding:encoding] action:@selector(changeEncodingAction:) keyEquivalent:@""];
			[menuItem setTag:encoding];
			[menuItem setTarget:self];
			[textEncodingMenu insertItem:menuItem atIndex:0];
		}
	}
	
	enumerator = [encodingsArray reverseObjectEnumerator];
	for (item in enumerator) {
		if ([[item valueForKey:@"active"] boolValue] == YES) {
			NSUInteger encoding = [[item valueForKey:@"encoding"] unsignedIntegerValue];
			menuItem = [[NSMenuItem alloc] initWithTitle:[NSString localizedNameOfStringEncoding:encoding] action:@selector(reloadText:) keyEquivalent:@""];
			[menuItem setTag:encoding];
			[menuItem setTarget:self];
			[reloadTextWithEncodingMenu insertItem:menuItem atIndex:0];
		}
	}
}

/*
 
 - buildSyntaxDefinitionsMenu
 
 */
- (void)buildSyntaxDefinitionsMenu
{
	NSArray *syntaxDefinitions = [SMLBasic fetchAll:@"SyntaxDefinitionSortKeySortOrder"];
	NSEnumerator *enumerator = [syntaxDefinitions reverseObjectEnumerator];
	NSMenuItem *menuItem;
	NSInteger tag = [syntaxDefinitions count] - 1;
	for (id item in enumerator) {
		menuItem = [[NSMenuItem alloc] initWithTitle:[item valueForKey:@"name"] action:@selector(changeSyntaxDefinitionAction:) keyEquivalent:@""];
		[menuItem setTag:tag];
		[menuItem setTarget:self];
		[syntaxDefinitionMenu insertItem:menuItem atIndex:0];
		tag--;
	}
	
}

/*
 
 - validateMenuItem:
 
 */
- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	BOOL enableMenuItem = YES;
	SEL action = [anItem action];
	
	id responder = [SMLCurrentWindow firstResponder];
	if (![responder isKindOfClass:[SMLTextView class]]) {
		return NO;
	}
	
	// All items who should only be active if something is selected
	if (action == @selector(removeNeedlessWhitespaceAction:) ||
		   action == @selector(removeLineEndingsAction:) ||
		   action == @selector(entabAction:) ||
		   action == @selector(detabAction:) ||
		   action == @selector(capitaliseAction:) ||
		   action == @selector(toUppercaseAction:) ||
		   action == @selector(toLowercaseAction:)
		   ) { 
		if ([SMLCurrentTextView selectedRange].length < 1) {
			enableMenuItem = NO;
		}
	}
    // Items which should be active if nothing is selected
    else if (action == @selector(toggleBreakpointAction:)) {
        if ([SMLCurrentTextView selectedRange].length > 0) {
            enableMenuItem = NO;
        }
    }
    // Comment Or Uncomment
    else if (action == @selector(commentOrUncommentAction:) ) {
		if ([[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] valueForKey:@"firstSingleLineComment"] isEqualToString:@""]) {
			enableMenuItem = NO;
		}
	} 
	
	return enableMenuItem;
}

/*
 
 - emptyDummyAction:
 
 */
- (IBAction)emptyDummyAction:(id)sender
{
	// An easy way to enable menu items with submenus without setting an action which actually does something
#pragma unused(sender)
}


#pragma mark -
#pragma mark Endcoding

/*
 
 - changeEncodingAction:
 
 */
- (void)changeEncodingAction:(id)sender
{	
	NSUInteger encoding = [sender tag];
	
	id document = SMLCurrentDocument;
	
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] registerUndoWithTarget:self selector:@selector(performUndoChangeEncoding:) object:[NSArray arrayWithObject:[document valueForKey:@"encoding"]]];
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] setActionName:NAME_FOR_UNDO_CHANGE_ENCODING];
	
	[document setValue:[NSNumber numberWithInteger:encoding] forKey:@"encoding"];
	[document setValue:[NSString localizedNameOfStringEncoding:encoding] forKey:@"encodingName"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MGSFragariaTextEncodingChanged" object:[MGSFragaria currentInstance] userInfo:nil];
}

/*
 
 - performUndoChangeEncoding:
 
 */
-(void)performUndoChangeEncoding:(id)sender
{
	id document = SMLCurrentDocument;
	
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] registerUndoWithTarget:self selector:@selector(performUndoChangeEncoding:) object:[NSArray arrayWithObject:[document valueForKey:@"encoding"]]];
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] setActionName:NAME_FOR_UNDO_CHANGE_ENCODING];
	
	[document setValue:[sender objectAtIndex:0] forKey:@"encoding"];
	[document setValue:[NSString localizedNameOfStringEncoding:[[sender objectAtIndex:0] unsignedIntegerValue]] forKey:@"encodingName"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MGSFragariaTextEncodingChanged" object:[MGSFragaria currentInstance] userInfo:nil];

}

#pragma mark -
#pragma mark Text shifting

/*
 
 - shiftLeftAction:
 
 */
- (IBAction)shiftLeftAction:(id)sender
{	
#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	
	NSString *completeString = [textView string];
	if ([completeString length] < 1) {
		return;
	}
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSRange selectedRange;
	
	NSArray *array = [SMLCurrentTextView selectedRanges];
	NSInteger sumOfAllCharactersRemoved = 0;
	NSInteger updatedLocation;
	NSMutableArray *updatedSelectionsArray = [NSMutableArray array];
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location - sumOfAllCharactersRemoved, [item rangeValue].length);
		NSUInteger temporaryLocation = selectedRange.location;
		NSUInteger maxSelectedRange = NSMaxRange(selectedRange);
		NSInteger numberOfLines = 0;
		NSInteger locationOfFirstLine = [completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)].location;

		do {
			temporaryLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)]);
			numberOfLines++;
		} while (temporaryLocation < maxSelectedRange);

		temporaryLocation = selectedRange.location;
		NSInteger idx;
		NSInteger charactersRemoved = 0;
		NSInteger charactersRemovedInSelection = 0;
		NSRange rangeOfLine;
		unichar characterToTest;
		NSInteger numberOfSpacesPerTab = [[SMLDefaults valueForKey:MGSFragariaPrefsIndentWidth] integerValue];
		NSInteger numberOfSpacesToDeleteOnFirstLine = -1;
		for (idx = 0; idx < numberOfLines; idx++) {
			rangeOfLine = [completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)];
			if ([[SMLDefaults valueForKey:MGSFragariaPrefsUseTabStops] boolValue] == YES && [[SMLDefaults valueForKey:MGSFragariaPrefsIndentWithSpaces] boolValue] == YES) {
				NSUInteger startOfLine = rangeOfLine.location;
				while (startOfLine < NSMaxRange(rangeOfLine) && [completeString characterAtIndex:startOfLine] == ' ' && rangeOfLine.length > 0) {
					startOfLine++;
				}
				NSInteger numberOfSpacesToDelete = numberOfSpacesPerTab;
				if (numberOfSpacesPerTab != 0) {
					numberOfSpacesToDelete = (startOfLine - rangeOfLine.location) % numberOfSpacesPerTab;
					if (numberOfSpacesToDelete == 0) {
						numberOfSpacesToDelete = numberOfSpacesPerTab;
					}
				}
				if (numberOfSpacesToDeleteOnFirstLine != -1) {
					numberOfSpacesToDeleteOnFirstLine = numberOfSpacesToDelete;
				}
				while (numberOfSpacesToDelete--) {
					characterToTest = [completeString characterAtIndex:rangeOfLine.location];
					if (characterToTest == ' ' || characterToTest == '\t') {
						if ([textView shouldChangeTextInRange:NSMakeRange(rangeOfLine.location, 1) replacementString:@""]) { // Do it this way to mark it as an Undo
							[textView replaceCharactersInRange:NSMakeRange(rangeOfLine.location, 1) withString:@""];
							[textView didChangeText];
						}
						charactersRemoved++;
						if (rangeOfLine.location >= selectedRange.location && rangeOfLine.location < maxSelectedRange) {
							charactersRemovedInSelection++;
						}
						if (characterToTest == '\t') {
							break;
						}
					}
				}
			} else {
				characterToTest = [completeString characterAtIndex:rangeOfLine.location];
				if ((characterToTest == ' ' || characterToTest == '\t') && rangeOfLine.length > 0) {
					if ([textView shouldChangeTextInRange:NSMakeRange(rangeOfLine.location, 1) replacementString:@""]) { // Do it this way to mark it as an Undo
						[textView replaceCharactersInRange:NSMakeRange(rangeOfLine.location, 1) withString:@""];
						[textView didChangeText];
					}			
					charactersRemoved++;
					if (rangeOfLine.location >= selectedRange.location && rangeOfLine.location < maxSelectedRange) {
						charactersRemovedInSelection++;
					}
				}
			}
			if (temporaryLocation < [[textView string] length]) {
				temporaryLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)]);
			}
		}

		if (selectedRange.length > 0) {
			NSInteger selectedRangeLocation = selectedRange.location; // Make the location into an NSInteger because otherwise the value gets all screwed up when subtracting from it
			NSInteger charactersToCountBackwards = 1;
			if (numberOfSpacesToDeleteOnFirstLine != -1) {
				charactersToCountBackwards = numberOfSpacesToDeleteOnFirstLine;
			}
			if (selectedRangeLocation - charactersToCountBackwards <= locationOfFirstLine) {
				updatedLocation = locationOfFirstLine;
			} else {
				updatedLocation = selectedRangeLocation - charactersToCountBackwards;
			}
			[updatedSelectionsArray addObject:[NSValue valueWithRange:NSMakeRange(updatedLocation, selectedRange.length - charactersRemovedInSelection)]];
		}
		sumOfAllCharactersRemoved = sumOfAllCharactersRemoved + charactersRemoved;
	}
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	if (sumOfAllCharactersRemoved == 0) {
		NSBeep();
	} else {
		if ([[SMLCurrentDocument valueForKey:MGSFOIsEdited] boolValue] == NO) {
			[self setEdited: YES];
		}
		[[SMLCurrentDocument valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
	}
	
	if ([updatedSelectionsArray count] > 0) {
		[textView setSelectedRanges:updatedSelectionsArray];
	}
}

/*
 
 - shiftRightAction:
 
 */
- (IBAction)shiftRightAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSString *completeString = [textView string];
	if ([completeString length] < 1) {
		return;
	}
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSRange selectedRange;
	
	NSMutableString *replacementString;
	if ([[SMLDefaults valueForKey:MGSFragariaPrefsIndentWithSpaces] boolValue] == YES) {
		replacementString = [NSMutableString string];
		NSInteger numberOfSpacesPerTab = [[SMLDefaults valueForKey:MGSFragariaPrefsIndentWidth] integerValue];
		if ([[SMLDefaults valueForKey:MGSFragariaPrefsUseTabStops] boolValue] == YES) {
			NSInteger locationOnLine = [textView selectedRange].location - [[textView string] lineRangeForRange:NSMakeRange([textView selectedRange].location, 0)].location;
			if (numberOfSpacesPerTab != 0) {
				NSInteger numberOfSpacesLess = locationOnLine % numberOfSpacesPerTab;
				numberOfSpacesPerTab = numberOfSpacesPerTab - numberOfSpacesLess;
			}
		}
		while (numberOfSpacesPerTab--) {
			[replacementString appendString:@" "];
		}
	} else {
		replacementString = [NSMutableString stringWithString:@"\t"];
	}
	NSInteger replacementStringLength = [replacementString length];
	
	NSArray *array = [SMLCurrentTextView selectedRanges];
	NSInteger sumOfAllCharactersInserted = 0;
	NSInteger updatedLocation;
	NSMutableArray *updatedSelectionsArray = [NSMutableArray array];
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location + sumOfAllCharactersInserted, [item rangeValue].length);
		NSUInteger temporaryLocation = selectedRange.location;
		NSUInteger maxSelectedRange = NSMaxRange(selectedRange);
		NSInteger numberOfLines = 0;
		NSInteger locationOfFirstLine = [completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)].location;
		
		do {
			temporaryLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)]);
			numberOfLines++;
		} while (temporaryLocation < maxSelectedRange);
		
		temporaryLocation = selectedRange.location;
		NSInteger idx;
		NSUInteger charactersInserted = 0;
		NSInteger charactersInsertedInSelection = 0;
		NSRange rangeOfLine;
		for (idx = 0; idx < numberOfLines; idx++) {
			rangeOfLine = [completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)];
			if ([textView shouldChangeTextInRange:NSMakeRange(rangeOfLine.location, 0) replacementString:replacementString]) { // Do it this way to mark it as an Undo
				[textView replaceCharactersInRange:NSMakeRange(rangeOfLine.location, 0) withString:replacementString];
				[textView didChangeText];
			}			
			charactersInserted = charactersInserted + replacementStringLength;
			if (rangeOfLine.location >= selectedRange.location && rangeOfLine.location < maxSelectedRange + charactersInserted) {
				charactersInsertedInSelection = charactersInsertedInSelection + replacementStringLength;
			}
			if (temporaryLocation < [[textView string] length]) {
				temporaryLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(temporaryLocation, 0)]);
			}	
		}
		
		if (selectedRange.length > 0) {
			if (selectedRange.location + replacementStringLength >= [[textView string] length]) {
				updatedLocation = locationOfFirstLine;
			} else {
				updatedLocation = selectedRange.location;
			}
			[updatedSelectionsArray addObject:[NSValue valueWithRange:NSMakeRange(updatedLocation, selectedRange.length + charactersInsertedInSelection)]];
		}
		sumOfAllCharactersInserted = sumOfAllCharactersInserted + charactersInserted;

	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	[self setEdited:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
	
	if ([updatedSelectionsArray count] > 0) {
		[textView setSelectedRanges:updatedSelectionsArray];
	}
}

#pragma mark -
#pragma mark Text manipulation

/*
 
 - interchangeAdjacentCharactersAction:
 
 */
- (IBAction)interchangeAdjacentCharactersAction:(id)sender
{
#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	[textView transpose:nil];
}

/*
 
 - removeNeedlessWhitespaceAction:
 
 */
- (IBAction)removeNeedlessWhitespaceAction:(id)sender
{
	#pragma unused(sender)
	
	// First count the number of lines in which to perform the action, as the original range changes when you insert characters, and then perform the action line after line, by removing tabs and spaces after the last non-whitespace characters in every line
	
	NSTextView *textView = SMLCurrentTextView;
	NSString *completeString = [textView string];
	if ([completeString length] < 1) {
		return;
	}
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSRange selectedRange;
	
	NSArray *array = [SMLCurrentTextView selectedRanges];
	NSInteger sumOfAllCharactersRemoved = 0;
	NSInteger updatedLocation;
	NSMutableArray *updatedSelectionsArray = [NSMutableArray array];
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location - sumOfAllCharactersRemoved, [item rangeValue].length);
		NSUInteger tempLocation = selectedRange.location;
		NSUInteger maxSelectedRange = NSMaxRange(selectedRange);
		NSInteger numberOfLines = 0;
		NSInteger locationOfFirstLine = [completeString lineRangeForRange:NSMakeRange(tempLocation, 0)].location;
		
		do {
			tempLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(tempLocation, 0)]);
			numberOfLines++;
		} while (tempLocation < maxSelectedRange);
		
		tempLocation = selectedRange.location;
		NSInteger idx;
		NSInteger charactersRemoved = 0;
		NSInteger charactersRemovedInSelection = 0;
		NSRange rangeOfLine;
		
		NSUInteger endOfContentsLocation;
		for (idx = 0; idx < numberOfLines; idx++) {
			rangeOfLine = [completeString lineRangeForRange:NSMakeRange(tempLocation, 0)];
			[completeString getLineStart:NULL end:NULL contentsEnd:&endOfContentsLocation forRange:rangeOfLine];
			
			while (endOfContentsLocation != 0 && ([completeString characterAtIndex:endOfContentsLocation - 1] == ' ' || [completeString characterAtIndex:endOfContentsLocation - 1] == '\t')) {
				if ([textView shouldChangeTextInRange:NSMakeRange(endOfContentsLocation - 1, 1) replacementString:@""]) { // Do it this way to mark it as an Undo
					[textView replaceCharactersInRange:NSMakeRange(endOfContentsLocation - 1, 1) withString:@""];
					[textView didChangeText];
				}
				endOfContentsLocation--;
				charactersRemoved++;
				if (rangeOfLine.location >= selectedRange.location && rangeOfLine.location < maxSelectedRange) {
					charactersRemovedInSelection++;
				}
			}
			tempLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(tempLocation, 0)]);		
		}
		
		if (selectedRange.length > 0) {
			NSInteger selectedRangeLocation = selectedRange.location; // Make the location into an NSInteger because otherwise the value gets all screwed up when subtracting from it
			if (selectedRangeLocation - 1 <= locationOfFirstLine) {
				updatedLocation = locationOfFirstLine;
			} else {
				updatedLocation = selectedRangeLocation - 1;
			}
			[updatedSelectionsArray addObject:[NSValue valueWithRange:NSMakeRange(updatedLocation, selectedRange.length - charactersRemoved)]];
		}
		sumOfAllCharactersRemoved = sumOfAllCharactersRemoved + charactersRemoved;
	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	if (sumOfAllCharactersRemoved == 0) {
		NSBeep();
	} else {
		[self setEdited:YES];
		[[SMLCurrentDocument valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
	}
	
	if ([updatedSelectionsArray count] > 0) {
		[textView setSelectedRanges:updatedSelectionsArray];
	}
}

/*
 
 - toLowercaseAction:
 
 */
- (IBAction)toLowercaseAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSArray *array = [textView selectedRanges];
	for (id item in array) {
		NSRange selectedRange = [item rangeValue];
		NSString *originalString = [SMLCurrentText substringWithRange:selectedRange];
		NSString *newString = [NSString stringWithString:[originalString lowercaseString]];
		[textView setSelectedRange:selectedRange];
		[textView insertText:newString];
	}
}

/*
 
 - toUppercaseAction:
 
 */
- (IBAction)toUppercaseAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSArray *array = [textView selectedRanges];
	for (id item in array) {
		NSRange selectedRange = [item rangeValue];
		NSString *originalString = [SMLCurrentText substringWithRange:selectedRange];
		NSString *newString = [NSString stringWithString:[originalString uppercaseString]];
		[textView setSelectedRange:selectedRange];
		[textView insertText:newString];
	}
}

/*
 
 - capitaliseAction:
 
 */
- (IBAction)capitaliseAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSArray *array = [textView selectedRanges];
	for (id item in array) {
		NSRange selectedRange = [item rangeValue];
		NSString *originalString = [SMLCurrentText substringWithRange:selectedRange];
		NSString *newString = [NSString stringWithString:[originalString capitalizedString]];
		[textView setSelectedRange:selectedRange];
		[textView insertText:newString];
	}
}

/*
 
 - entabAction:
 
 */
- (IBAction)entabAction:(id)sender
{
	#pragma unused(sender)
	
	[SMLCurrentExtraInterfaceController displayEntab];
}

/*
 
 - detabAction
 
 */
- (IBAction)detabAction:(id)sender
{
	#pragma unused(sender)
	
	[SMLCurrentExtraInterfaceController displayDetab];
}


/*
 
 - performEntab
 
 */
- (void)performEntab
{	
	NSTextView *textView = SMLCurrentTextView;
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSRange selectedRange;
	NSRange savedRange = [textView selectedRange];
	
	NSArray *array = [SMLCurrentTextView selectedRanges];
	NSMutableString *searchString = [NSMutableString string];
	NSInteger numberOfSpaces = [[SMLDefaults valueForKey:MGSFragariaPrefsSpacesPerTabEntabDetab] integerValue];
	while (numberOfSpaces--) {
		[searchString appendString:@" "];
	}
	NSMutableString *completeString = [NSMutableString stringWithString:[textView string]];
	NSInteger sumOfRemovedCharacters = 0;
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location - sumOfRemovedCharacters, [item rangeValue].length);
	
		sumOfRemovedCharacters = sumOfRemovedCharacters + ([completeString replaceOccurrencesOfString:searchString withString:@"\t" options:NSLiteralSearch range:selectedRange] * ([searchString length] - 1));
		
		if ([textView shouldChangeTextInRange:NSMakeRange(0, [[textView string] length]) replacementString:completeString]) { // Do it this way to mark it as an Undo
			[textView replaceCharactersInRange:NSMakeRange(0, [[textView string] length]) withString:completeString];
			[textView didChangeText];
		}

	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[self setEdited:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];

	[textView setSelectedRange:NSMakeRange(savedRange.location, 0)];
}

/*
 
 - performDetab
 
 */
- (void)performDetab
{	
	NSTextView *textView = SMLCurrentTextView;
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSRange selectedRange;
	NSRange savedRange = [textView selectedRange];
	
	NSArray *array = [SMLCurrentTextView selectedRanges];
	NSMutableString *replacementString = [NSMutableString string];
	NSInteger numberOfSpaces = [[SMLDefaults valueForKey:MGSFragariaPrefsSpacesPerTabEntabDetab] integerValue];
	while (numberOfSpaces--) {
		[replacementString appendString:@" "];
	}
	NSMutableString *completeString = [NSMutableString stringWithString:[textView string]];
	NSInteger sumOfInsertedCharacters = 0;
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location + sumOfInsertedCharacters, [item rangeValue].length);
		
		sumOfInsertedCharacters = sumOfInsertedCharacters + ([completeString replaceOccurrencesOfString:@"\t" withString:replacementString options:NSLiteralSearch range:selectedRange] * ([replacementString length] - 1));
		
		if ([textView shouldChangeTextInRange:NSMakeRange(0, [[textView string] length]) replacementString:completeString]) { // Do it this way to mark it as an Undo
			[textView replaceCharactersInRange:NSMakeRange(0, [[textView string] length]) withString:completeString];
			[textView didChangeText];
		}
		
	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[self setEdited:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	[textView setSelectedRange:NSMakeRange(savedRange.location, 0)];
}

/*
 
 - reloadText:
 
 */
- (void)reloadText:(id)sender
{
#pragma unused(sender)
	
	id document = SMLCurrentDocument;
	[document setValue:[NSNumber numberWithUnsignedInteger:[sender tag]] forKey:@"encoding"];
	[document setValue:[NSString localizedNameOfStringEncoding:[sender tag]] forKey:@"encodingName"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MGSFragariaReloadText" object:[MGSFragaria currentInstance] userInfo:nil];
}

#pragma mark -
#pragma mark Goto

/*
 
 - goToLineAction:
 
 */
- (IBAction)goToLineAction:(id)sender
{
	#pragma unused(sender)
	
	[SMLCurrentExtraInterfaceController displayGoToLine];
}


/*
 
 - performGoToLine:
 
 */
- (void)performGoToLine:(NSInteger)lineToGoTo
{
  [[MGSFragaria currentInstance] goToLine:lineToGoTo centered:NO highlight:YES];
}

#pragma mark -
#pragma mark Tag manipulation


/*
 
 - closeTagAction:
 
 */
- (IBAction)closeTagAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	
	NSRange selectedRange = [textView selectedRange];
	if (selectedRange.length > 0) {
		NSBeep();
		return;
	}
	
	NSUInteger location = selectedRange.location;
	NSString *completeString = [textView string];
	BOOL foundClosingBrace = NO;
	BOOL foundOpeningBrace = NO;
	
	while (location--) { // First check that there is a closing c i.e. >
		if ([completeString characterAtIndex:location] == '>') {
			foundClosingBrace = YES;
			break;
		}
	}
	
	if (!foundClosingBrace) {
		NSBeep();
		return;
	}
	
	NSInteger locationOfClosingBrace = location;
	NSInteger numberOfClosingTags = 0;
	
	while (location--) { // Then check for the opening brace i.e. <
		if ([completeString characterAtIndex:location] == '<') {
			// Divide into four checks as otherwise it will miss to skip the tag if it comes absolutely last in the document  
			if (location + 4 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
				NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 4)];
				NSRange searchRange = NSMakeRange(0, [checkString length]);
				if ([checkString rangeOfString:@"<br>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<hr>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<!--" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<?" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<%" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				}
			}
			
			if (location + 5 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
				NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 5)];
				NSRange searchRange = NSMakeRange(0, [checkString length]);
				if ([checkString rangeOfString:@"<img " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<br/>" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				}
			}
			
			if (location + 6 <= [completeString length]) { // Check that the tag is not one of the tags that aren't closed e.g. <br> or any of their variants
				NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 6)];
				NSRange searchRange = NSMakeRange(0, [checkString length]);
				if ([checkString rangeOfString:@"<br />" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<hr />" options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<area " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<base " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<link " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<meta " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				}
			}
			
			if (location + 7 < [completeString length]) { // check that the tag is not one of the tags that aren't closed e.g. <br> and their variants
				NSString *checkString = [completeString substringWithRange:NSMakeRange(location, 7)];
				NSRange searchRange = NSMakeRange(0, [checkString length]);
				if ([checkString rangeOfString:@"<frame " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<input " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				} else if ([checkString rangeOfString:@"<param " options:NSCaseInsensitiveSearch range:searchRange].location != NSNotFound) {
					continue;
				}
			}
			
			NSScanner *selfClosingScanner = [NSScanner scannerWithString:[completeString substringWithRange:NSMakeRange(location, locationOfClosingBrace - location)]];
			[selfClosingScanner setCharactersToBeSkipped:nil];
			NSString *selfClosingScanString = [NSString string];
			[selfClosingScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@">"] intoString:&selfClosingScanString]; 
			
			if ([selfClosingScanString length] != 0) {
				if ([selfClosingScanString characterAtIndex:([selfClosingScanString length] - 1)] == '/') {
					continue;
				}
			}
			
			if ([completeString characterAtIndex:location + 1] == '/') { // If it's a closing tag (e.g. </a>) continue the search
				numberOfClosingTags++; 
				continue;
			} else {				
				if (numberOfClosingTags) { // Try to find the "correct" tag to close by counting the number of closing tags and when they match up insert the created closing tag; if they don't write balanced code - well, tough luck...
					numberOfClosingTags--;
				} else {
					foundOpeningBrace = YES;
					break;
				}
			}
		}
	}
	
	if (foundOpeningBrace == NO) {
		NSBeep();
		return;
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:[completeString substringWithRange:NSMakeRange(location, locationOfClosingBrace - location)]];
	[scanner setCharactersToBeSkipped:nil];
	NSString *scanString = [NSString string];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" >/"] intoString:&scanString]; // Set the string to everything up to any of the characters (space),> or / so that it will catch things like <a href... as well as <br>
	
	NSMutableString *tagString = [NSMutableString stringWithString:scanString];
	NSInteger tagStringLength = [tagString length];
	if (tagStringLength == 0) {
		NSBeep();
		return;
	}
	
	[tagString insertString:@"/" atIndex:1];
	[tagString insertString:@">" atIndex:tagStringLength + 1];
	
	if ([textView shouldChangeTextInRange:selectedRange replacementString:tagString]) { // Do it this way to mark it as an Undo
		[textView replaceCharactersInRange:selectedRange withString:tagString];
		[textView didChangeText];
	}
}

/*
 
 - prepareForXMLAction:
 
 */
- (IBAction)prepareForXMLAction:(id)sender
{
#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSRange selectedRange = [textView selectedRange];
	NSMutableString *stringToConvert = [NSMutableString stringWithString:[[textView string] substringWithRange:selectedRange]];
	[stringToConvert replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [stringToConvert length])];
	[stringToConvert replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [stringToConvert length])];
	[stringToConvert replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [stringToConvert length])];
	[stringToConvert replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [stringToConvert length])];
	if ([textView shouldChangeTextInRange:selectedRange replacementString:stringToConvert]) { // Do it this way to mark it as an Undo
		[textView replaceCharactersInRange:selectedRange withString:stringToConvert];
		[textView didChangeText];
	}	
}

#pragma mark -
#pragma mark Breakpoints

- (IBAction)toggleBreakpointAction:(id)sender
{
    #pragma unused(sender)
    NSLog(@"toggleBreakpointAction");
}

#pragma mark -
#pragma mark Comment handling

/*
 
 - commentOrUncommentAction:
 
 */
- (IBAction)commentOrUncommentAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSString *completeString = [textView string];
	NSString *commentString = [[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] valueForKey:@"firstSingleLineComment"];
	NSUInteger commentStringLength = [commentString length];
	if ([commentString isEqualToString:@""] || [completeString length] < commentStringLength) {
		NSBeep();
		return;
	}
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	
	NSArray *array = [textView selectedRanges];
	NSRange selectedRange = NSMakeRange(0, 0);
	NSInteger sumOfChangedCharacters = 0;
	NSMutableArray *updatedSelectionsArray = [NSMutableArray array];
	for (id item in array) {
		selectedRange = NSMakeRange([item rangeValue].location + sumOfChangedCharacters, [item rangeValue].length);
	
		NSUInteger tempLocation = selectedRange.location;
		NSUInteger maxSelectedRange = NSMaxRange(selectedRange);
		NSInteger numberOfLines = 0;
		NSInteger locationOfFirstLine = [completeString lineRangeForRange:NSMakeRange(tempLocation, 0)].location;
		
		BOOL shouldUncomment = NO;
		NSInteger searchLength = commentStringLength;
		if ((tempLocation + commentStringLength) > [completeString length]) {
			searchLength = 0;
		}
		
		if ([completeString rangeOfString:commentString options:NSCaseInsensitiveSearch range:NSMakeRange(tempLocation, searchLength)].location != NSNotFound) {
			shouldUncomment = YES; // The first line of the selection is already commented and thus we should uncomment
		} else if ([completeString rangeOfString:commentString options:NSCaseInsensitiveSearch range:NSMakeRange(locationOfFirstLine, searchLength)].location != NSNotFound) {
			shouldUncomment = YES; // Check the beginning of the line too
		} else { // Also check the first character after the whitespace
			NSInteger firstCharacterOfFirstLine = locationOfFirstLine;
			while ([completeString characterAtIndex:firstCharacterOfFirstLine] == ' ' || [completeString characterAtIndex:firstCharacterOfFirstLine] == '\t') {
				firstCharacterOfFirstLine++;
			}
			if ([completeString rangeOfString:commentString options:NSCaseInsensitiveSearch range:NSMakeRange(firstCharacterOfFirstLine, searchLength)].location != NSNotFound) {
				shouldUncomment = YES;
			}
		}
		
		do {
			tempLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(tempLocation, 0)]);
			numberOfLines++;
		} while (tempLocation < maxSelectedRange);
		NSInteger locationOfLastLine = tempLocation;
		
		tempLocation = selectedRange.location;
		NSInteger idx;
		NSInteger charactersInserted = 0;
		NSRange rangeOfLine;
		NSInteger firstCharacterOfLine;
		
		for (idx = 0; idx < numberOfLines; idx++) {
			rangeOfLine = [completeString lineRangeForRange:NSMakeRange(tempLocation, 0)];
			if (shouldUncomment == NO) {
				if ([textView shouldChangeTextInRange:NSMakeRange(rangeOfLine.location, 0) replacementString:commentString]) { // Do it this way to mark it as an Undo
					[textView replaceCharactersInRange:NSMakeRange(rangeOfLine.location, 0) withString:commentString];
					[textView didChangeText];
				}			
				charactersInserted = charactersInserted + commentStringLength;
			} else {
				firstCharacterOfLine = rangeOfLine.location;
				while ([completeString characterAtIndex:firstCharacterOfLine] == ' ' || [completeString characterAtIndex:firstCharacterOfLine] == '\t') {
					firstCharacterOfLine++;
				}
				if ([completeString rangeOfString:commentString options:NSCaseInsensitiveSearch range:NSMakeRange(firstCharacterOfLine, [commentString length])].location != NSNotFound) {
					if ([textView shouldChangeTextInRange:NSMakeRange(firstCharacterOfLine, commentStringLength) replacementString:@""]) { // Do it this way to mark it as an Undo
						[textView replaceCharactersInRange:NSMakeRange(firstCharacterOfLine, commentStringLength) withString:@""];
						[textView didChangeText];
					}		
					charactersInserted = charactersInserted - commentStringLength;
				}
			}
			tempLocation = NSMaxRange([completeString lineRangeForRange:NSMakeRange(tempLocation, 0)]);
		}
		sumOfChangedCharacters = sumOfChangedCharacters + charactersInserted;
		[updatedSelectionsArray addObject:[NSValue valueWithRange:NSMakeRange(locationOfFirstLine, locationOfLastLine - locationOfFirstLine + charactersInserted)]];
	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	[self setEdited:YES];
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
	
	if (selectedRange.length > 0) {
		[textView setSelectedRanges:updatedSelectionsArray];
	}

}

#pragma mark -
#pragma mark Line endings

/*
 
 - removeLineEndingsAction:
 
 */
- (IBAction)removeLineEndingsAction:(id)sender
{
	#pragma unused(sender)
	
	NSTextView *textView = SMLCurrentTextView;
	NSString *text = [textView string];
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:NO];
	NSArray *array = [textView selectedRanges];
	NSInteger sumOfDeletedLineEndings = 0;
	NSMutableArray *updatedSelectionsArray = [NSMutableArray array];
	for (id item in array) {
		NSRange selectedRange = NSMakeRange([item rangeValue].location - sumOfDeletedLineEndings, [item rangeValue].length);
		NSString *stringToRemoveLineEndingsFrom = [text substringWithRange:selectedRange];
		NSInteger originalLength = [stringToRemoveLineEndingsFrom length];
		NSString *stringWithNoLineEndings = [SMLText removeAllLineEndingsInString:stringToRemoveLineEndingsFrom];
		NSInteger newLength = [stringWithNoLineEndings length];
		if ([textView shouldChangeTextInRange:NSMakeRange(selectedRange.location, originalLength) replacementString:stringWithNoLineEndings]) { // Do it this way to mark it as an Undo
			[textView replaceCharactersInRange:NSMakeRange(selectedRange.location, originalLength) withString:stringWithNoLineEndings];
			[textView didChangeText];
		}			
		sumOfDeletedLineEndings = sumOfDeletedLineEndings + (originalLength - newLength);
		
		[updatedSelectionsArray addObject:[NSValue valueWithRange:NSMakeRange(selectedRange.location, newLength)]];
	}
	
	[[SMLCurrentDocument valueForKey:ro_MGSFOSyntaxColouring] setReactToChanges:YES];
	
	[self setEdited:YES];	
	[[SMLCurrentDocument valueForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:YES recolour:YES];
	
	if ([updatedSelectionsArray count] > 0) {
		[textView setSelectedRanges:updatedSelectionsArray];
	}
}

/*
 
 - changeLineEndingsAction:
 
 */
- (IBAction)changeLineEndingsAction:(id)sender
{
	id document = SMLCurrentDocument;
	
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] registerUndoWithTarget:self selector:@selector(performUndoChangeLineEndings:) object:[NSArray arrayWithObject:[document valueForKey:@"lineEndings"]]];
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] setActionName:NAME_FOR_UNDO_CHANGE_LINE_ENDINGS];
	
	[document setValue:[NSNumber numberWithInteger:[sender tag] - 150] forKey:@"lineEndings"];
	
	NSTextView *textView = SMLCurrentTextView;
	NSRange selectedRange = [textView selectedRange];
	NSString *text = [textView string];
	NSString *convertedString = [SMLText convertLineEndings:text inDocument:document];
	[textView replaceCharactersInRange:NSMakeRange(0, [text length]) withString:convertedString];
	[textView setSelectedRange:selectedRange];
	
	[[document valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	[self setEdited:YES];
}

/*
 
 - performUndoChangeLineEndings:
 
 */
- (void)performUndoChangeLineEndings:(id)sender
{
	id document = SMLCurrentDocument;
	
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] registerUndoWithTarget:self selector:@selector(performUndoChangeLineEndings:) object:[NSArray arrayWithObject:[document valueForKey:@"lineEndings"]]];
	[[[document valueForKey:ro_MGSFOSyntaxColouring] undoManager] setActionName:NAME_FOR_UNDO_CHANGE_LINE_ENDINGS];
	
	[document setValue:[sender objectAtIndex:0] forKey:@"lineEndings"];
	
	NSTextView *textView = SMLCurrentTextView;
	NSRange selectedRange = [textView selectedRange];
	NSString *text = [textView string];
	NSString *convertedString = [SMLText convertLineEndings:text inDocument:document];
	[textView replaceCharactersInRange:NSMakeRange(0, [text length]) withString:convertedString];
	[textView setSelectedRange:selectedRange];
	
	[[document valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	
	[self setEdited:YES];
}

#pragma mark -
#pragma mark Syntax definition handling

/*
 
 - changeSyntaxDefinitionAction:
 
 */
- (IBAction)changeSyntaxDefinitionAction:(id)sender
{
	id document = SMLCurrentDocument;
	[document setValue:[sender title] forKey:MGSFOSyntaxDefinitionName];
	[document setValue:[NSNumber numberWithBool:YES] forKey:@"hasManuallyChangedSyntaxDefinition"];
	[[document valueForKey:ro_MGSFOSyntaxColouring] applySyntaxDefinition];
	
	[[document valueForKey:ro_MGSFOSyntaxColouring] pageRecolour];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MGSFragariaSyntaxDefinitionChanged" object:[MGSFragaria currentInstance] userInfo:nil];

}
@end
