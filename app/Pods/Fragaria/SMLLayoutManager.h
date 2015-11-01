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


enum {
    MGSUnderlineStyleSquiggly = 0x0F
};


/**
 *  SMLLayoutManager handles the layout of all of the glyphs in the text editor.
 **/
@interface SMLLayoutManager : NSLayoutManager

/**
 *  Returns an attributed string with temporary attributes having been
 *  applied as standard attributes.
 **/
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied;

/**
 *  Specifies the font for drawing invisible characters.
 **/
@property (nonatomic) NSFont *invisibleCharactersFont;

/**
 *  Specifies the color for drawing invisible characters.
 **/
@property (nonatomic) NSColor *invisibleCharactersColour;

/**
 *  Indicates whether or not glyphs for invisible characters will
 *  appear in the text editor.
 **/
@property BOOL showsInvisibleCharacters;


@end
