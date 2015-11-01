//
//  NSString+Fragaria.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 16/05/15.
//
//

#import <Foundation/Foundation.h>


/**
 *  A private category which adds helper functions to NSString.
 */

@interface NSString (Fragaria)


/** The real location of the specified character index in this line, in
 *  characters.
 *  @discussion This method takes in account the real width of tabulation
 *              characters, and ignores newlines.
 *  @param c A character index in the line string.
 *  @param tabwidth The width of a tab. */
- (NSUInteger)mgs_columnOfCharacter:(NSUInteger)c tabWidth:(NSUInteger)tabwidth;


@end
