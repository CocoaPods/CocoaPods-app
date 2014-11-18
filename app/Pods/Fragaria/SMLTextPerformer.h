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

#import <Cocoa/Cocoa.h>


@interface SMLTextPerformer : NSObject {

	NSString *darkSideLineEnding;
	NSString *macLineEnding;
	NSString *unixLineEnding;
	
	NSString *newLineSymbolString;
}

+ (SMLTextPerformer *)sharedInstance;

- (NSString *)convertLineEndings:(NSString *)stringToConvert inDocument:(id)document;

- (NSStringEncoding)guessEncodingFromData:(NSData *)textData;

- (NSString *)replaceAllNewLineCharactersWithSymbolInString:(NSString *)theTextString;

- (NSString *)removeAllLineEndingsInString:(NSString *)string;



@end
