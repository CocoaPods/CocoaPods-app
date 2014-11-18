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
#import "NSScanner+Fragaria.h"

@implementation SMLTextPerformer

static id sharedInstance = nil;

#pragma mark -
#pragma mark Class methods

/*
 
 + sharedInstance
 
 */
+ (SMLTextPerformer *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	}
	
	return sharedInstance;
} 

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init 
{
    if (sharedInstance == nil) {
        self = [super init];
        sharedInstance = self;
        
		darkSideLineEnding = [[NSString alloc] initWithFormat:@"%d%d", 0x000D, 0x000A];
		macLineEnding = [[NSString alloc] initWithFormat:@"%d", 0x000D];
		unixLineEnding = [[NSString alloc] initWithFormat:@"%d", 0x000A];
		newLineSymbolString = [[NSString alloc] initWithFormat:@"%d", 0x23CE];
    }
    return sharedInstance;
}

#pragma mark -
#pragma mark Text manipulation

/*
 
 - convertLineEndings:inDocument:
 
 */
- (NSString *)convertLineEndings:(NSString *)stringToConvert inDocument:(id)document
{
	NSInteger lineEndings;
	if ([[document valueForKey:@"lineEndings"] integerValue] == 0) { // It hasn't been changed by the user so use the one from the defaults
		lineEndings = [[SMLDefaults valueForKey:@"LineEndingsPopUp"] integerValue] + 1;
	} else {
		lineEndings = [[document valueForKey:@"lineEndings"] integerValue];
	}

	if (lineEndings == SMLLeaveLineEndingsUnchanged) { 
		return stringToConvert;
	}
	
	NSMutableString *returnString = [NSMutableString stringWithString:stringToConvert];
	
	if (lineEndings == SMLDarkSideLineEndings) { // CRLF
		[returnString replaceOccurrencesOfString:darkSideLineEnding withString:unixLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])]; // So that it doesn't change macLineEnding part of darkSideLineEnding
		[returnString replaceOccurrencesOfString:macLineEnding withString:unixLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
		[returnString replaceOccurrencesOfString:unixLineEnding withString:darkSideLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
		
	} else if (lineEndings == SMLMacLineEndings) { // CR
		[returnString replaceOccurrencesOfString:darkSideLineEnding withString:macLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
		[returnString replaceOccurrencesOfString:unixLineEnding withString:macLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
		
	} else { // LF
		[returnString replaceOccurrencesOfString:darkSideLineEnding withString:unixLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
		[returnString replaceOccurrencesOfString:macLineEnding withString:unixLineEnding options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	}
	
	return (NSString *)returnString;
}


/*
 
 - guessEncodingFromData:
 
 */
- (NSStringEncoding)guessEncodingFromData:(NSData *)textData
{
	NSString *string = [[NSString alloc] initWithData:textData encoding:NSISOLatin1StringEncoding];
	NSStringEncoding encoding = 0;
	BOOL foundExplicitEncoding = NO;
	
	if ([string length] > 9) { // If it's shorter than this you can't check for encoding string
		NSScanner *scannerHTML = [[NSScanner alloc] initWithString:string];
		NSUInteger beginning;
		NSInteger end;
		
		[scannerHTML scanUpToString:@"charset=" intoString:nil]; // Search first for "charset=" (html) and get the string after that
		if ([scannerHTML scanLocation] < [string length] - 8) { 
			beginning = [scannerHTML scanLocation] + 8; // Place it after the =
			if (beginning + 1 < [string length] && [string characterAtIndex:beginning] == '"') { // If the encoding is within quotes
				beginning++;
			}
			[scannerHTML mgs_setScanLocation:beginning];
			[scannerHTML scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"' />"] intoString:nil];
			end = [scannerHTML scanLocation];

			encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[string substringWithRange:NSMakeRange(beginning, end - beginning)]));
			foundExplicitEncoding = YES;
		} else {
			NSScanner *scannerXML = [[NSScanner alloc] initWithString:string];
			[scannerXML scanUpToString:@"encoding=" intoString:nil]; // If not found, search for "encoding=" (xml) and get the string after that
			if ([scannerXML scanLocation] < [string length] - 9) { 
				beginning = [scannerXML scanLocation] + 9 + 1; // After the " or '
				[scannerXML scanUpToString:@"?>" intoString:nil];
				end = [scannerXML scanLocation] - 1; // -1 to get rid of " or '
				encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[string substringWithRange:NSMakeRange(beginning, end - beginning)]));
				foundExplicitEncoding = YES;
			}
		}
	}
	
	// If the scanner hasn't found an explicitly defined encoding, check for either EFBBBF, FEFF or FFFE and, if found, set the encoding to UTF-8 or UTF-16
	if (!foundExplicitEncoding && [textData length] > 2) {
		NSString *lookForEncodingInBytesString = [NSString stringWithString:[textData description]];
		if ([[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,6)] isEqualToString:@"efbbbf"]) encoding = NSUTF8StringEncoding;
		else if ([[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,4)] isEqualToString:@"feff"] || [[lookForEncodingInBytesString substringWithRange:NSMakeRange(1,4)] isEqualToString:@"fffe"]) encoding = NSUnicodeStringEncoding;
	}

	return encoding;
}

/*
 
 - replaceAllNewLineCharactersWithSymbolInString:
 
 */
- (NSString *)replaceAllNewLineCharactersWithSymbolInString:(NSString *)string
{
	// To remove all newline characters in textString and replace it with a symbol, use NSMakeRange every time as the length changes
	NSMutableString *returnString = [NSMutableString stringWithString:string];
	
	[returnString replaceOccurrencesOfString:darkSideLineEnding withString:newLineSymbolString options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:macLineEnding withString:newLineSymbolString options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:unixLineEnding withString:newLineSymbolString options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	
	return returnString;
}

/*
 
 - removeAllLineEndingsInString:
 
 */
- (NSString *)removeAllLineEndingsInString:(NSString *)string
{
	NSMutableString *returnString = [NSMutableString stringWithString:string];
	[returnString replaceOccurrencesOfString:darkSideLineEnding withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:macLineEnding withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:unixLineEnding withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	
	return returnString;
}

@end
