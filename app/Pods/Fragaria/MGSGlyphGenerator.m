//
//  MGSGlyphGenerator.m
//  Fragaria
//
//  Created by Jonathan on 23/09/2012.
//
//

#import "MGSGlyphGenerator.h"

@implementation MGSGlyphGenerator

/*
 
 - generateGlyphsForGlyphStorage:desiredNumberOfCharacters:glyphIndex:characterIndex:
 
 */
- (void)generateGlyphsForGlyphStorage:(id <NSGlyphStorage>)glyphStorage
            desiredNumberOfCharacters:(NSUInteger)nChars
                           glyphIndex:(NSUInteger *)glyphIndex
                       characterIndex:(NSUInteger *)charIndex
{
    NSGlyphGenerator *instance = [NSGlyphGenerator sharedGlyphGenerator];
    
    _destination = glyphStorage;
    [instance generateGlyphsForGlyphStorage:self desiredNumberOfCharacters:nChars glyphIndex:glyphIndex characterIndex:charIndex];
    _destination = nil;
}

/*
 
 - insertGlyphs:length:forStartingGlyphAtIndex:characterIndex:
 
 see https://svn.r-project.org/R-packages/trunk/Mac-GUI/RScriptEditorGlyphGenerator.m
 
 */
- (void)insertGlyphs:(const NSGlyph *)glyphs
                    length:(NSUInteger)length
    forStartingGlyphAtIndex:(NSUInteger)glyphIndex
        characterIndex:(NSUInteger)charIndex
{
       
    // this is calling the layoutmanager method so glyph substitution can be performed there also
    [_destination insertGlyphs:glyphs
                        length:length
       forStartingGlyphAtIndex:glyphIndex
                characterIndex:charIndex];
}

/*
 
 - attributedString

 */
- (NSAttributedString *)attributedString
{  
    return [_destination attributedString];
}

/*
 
 - layoutOptions
 
 */
- (NSUInteger)layoutOptions
{
    return [_destination layoutOptions];
}

/*
 
 - setIntAttribute:value:forGlyphAtIndex:
 
 */
- (void)setIntAttribute:(NSInteger)attributeTag value:(NSInteger)val forGlyphAtIndex:(NSUInteger)glyphIndex
{
    [_destination setIntAttribute:attributeTag value:val forGlyphAtIndex:glyphIndex];
}
@end
