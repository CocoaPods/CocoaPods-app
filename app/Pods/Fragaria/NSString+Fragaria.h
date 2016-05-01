//
//  NSString+Fragaria.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 16/05/15.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>


/**
 *  A private category which adds helper functions to NSString.
 */

@interface NSString (Fragaria)


/** The real location of the specified character index in this line, in
 *  characters.
 *  @discussion This method takes in account the real width of tabulation
 *              characters. Newlines are treated like infinite-width tabs.
 *  @param c A character index in the line string.
 *  @param tabwidth The width of a tab. */
- (NSUInteger)mgs_columnOfCharacter:(NSUInteger)c tabWidth:(NSUInteger)tabwidth;

/** Returns the character index in this row that corresponds to the specified
 *  column (measured in characters).
 *  @discussion This method takes in account the real width of tabulation
 *              characters. Newlines are treated like infinite-width tabs.
 *  @param c A column number.
 *  @param tabwidth The width of a tab. */
- (NSUInteger)mgs_characterInColumn:(NSUInteger)c tabWidth:(NSUInteger)tabwidth;

/** Returns the range of characters representing the line containing a given
 *  character.
 *  @param i A character index in the string. 
 *  @returns If i points to a valid index in the string, calling this method
 *     is equivalent to calling [self lineRangeForRange:NSMakeRange(i, 0)].
 *     In all other cases, this function returns a range with NSNotFound as
 *     location, and 0 as length. */
- (NSRange)mgs_lineRangeForCharacterIndex:(NSUInteger)i;


@end
