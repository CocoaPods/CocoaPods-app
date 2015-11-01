//
//  MGSMutableSubstring.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 15/05/15.
//
//

#import <Foundation/Foundation.h>


/** 
 *  MGSMutableSubstring is a mutable string which wraps a range of another
 *  mutable string. This is to simplify index calculation when multiple
 *  disjointed ranges of a string are to be edited in sequence. 
 *
 *  When MGSMutableSubstring is edited, the mutable string of which it is a
 *  substring is edited in the same way.
 */

@interface MGSMutableSubstring : NSMutableString


/** Designated initializer. Returns an initialized MGSMutableSubstring made
 *  from a range of a given string.
 *  @param r The range of the superstring to be isolated.
 *  @param s The superstring. */
- (instancetype)initWithRange:(NSRange)r ofSuperstring:(NSMutableString *)s;

/** Returns a string made from a range of a given string.
 *  @param r The range of the superstring to be isolated.
 *  @param s The superstring. */
+ (instancetype)substringInRange:(NSRange)r ofString:(NSMutableString *)s;


/** Returns the range in the superstring which maps to the given range in this
 *  string.
 *  @param aRange A valid range for this string.*/
- (NSRange)superstringRangeFromRange:(NSRange)aRange;

/** Returns the range in the superstring which maps to this whole string. */
- (NSRange)superstringRange;

/** Returns the string wrapped by this string. */
- (NSMutableString *)superstring;


@end


/** 
 *  This category implements utility methods for working with 
 *  MGSMutableSubstring.
 */

@interface NSMutableString (MutableSubstring)


/** Enumerates with the given block the ranges contained in an array.
 *  @param a An array of NSRanges.
 *  @param b The block to be used for enumerating.
 *
 *    - *substring* The MGSMutableSubstring for this range
 *    - *stop* A BOOL you may set to YES if you want to stop the enumeration.
 *  @discussion This methods takes in account your edits to the substrings
 *              and shifts the ranges in the input array accordingly. */
- (NSArray *)enumerateMutableSubstringsFromRangeArray:(NSArray*)a usingBlock:
  (void (^)(MGSMutableSubstring *substring, BOOL *stop))b;

/** Enumerates with the given block every line in the string.
 *  @param b The block to be used for enumerating.
 *
 *    - *substring* The MGSMutableSubstring for this line
 *    - *stop* A BOOL you may set to YES if you want to stop the enumeration.
 *  @discussion This methods takes in account your edits to the lines
 *              and shifts the ranges in the input array accordingly. Each
 *              newly enumerated line always starts from the end of the lastly
 *              enumerated line, even if newline characters were added or
 *              removed from it. For example, if while enumerating the substring
 *              "abc\n" of the superstring "abc\ndef\nghi" the newline is
 *              removed, the next substring in the enumeration will be "def\n",
 *              not "ghi". */
- (void)enumerateMutableSubstringsOfLinesUsingBlock:(void (^)
  (MGSMutableSubstring *substring, BOOL *stop))b;

/** Returns a mutable substring mapped to the substring trailing the characters
 *  from the given character set.
 *  @param cs A character set. */
- (MGSMutableSubstring *)mutableSubstringByLeftTrimmingCharactersFromSet:
  (NSCharacterSet *)cs;

@end

