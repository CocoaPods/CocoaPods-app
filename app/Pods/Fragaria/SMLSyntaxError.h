//
//  SMLSyntaxError.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//


#import <Foundation/Foundation.h>


/** @defgroup warninglevels SMLSyntaxError Warning Levels
 *  These are Fragaria's default warning levels. Warning levels are used to
 *  decide which error badge will be shown on a line if more than one error
 *  is located on that line. Also, when the warningLevel property is set, the
 *  SMLSyntaxError's default image will also be set to one of various predefined
 *  images; each of these images correspond to one of the following
 *  constants. */

/** @{ */
extern float const kMGSErrorCategoryAccess;   ///<          warningLevel < 100.0
extern float const kMGSErrorCategoryConfig;   ///< 100.0 <= warningLevel < 200.0
extern float const kMGSErrorCategoryDocument; ///< 200.0 <= warningLevel < 300.0
extern float const kMGSErrorCategoryInfo;     ///< 300.0 <= warningLevel < 400.0
extern float const kMGSErrorCategoryWarning;  ///< 400.0 <= warningLevel < 500.0
extern float const kMGSErrorCategoryError;    ///< 500.0 <= warningLevel < 600.0
extern float const kMGSErrorCategoryPanic;    ///< 600.0 <= warningLevel
extern float const kMGSErrorCategoryDefault;  ///< kMGSErrorCategoryWarning
/** @} */


/** 
 *  SMLSyntaxError is a model class that stores the syntax errors to be
 *  shown in Fragaria's text view and gutter.
 *
 *  @discussion Components using this class are not currently KVO compliant and
 *              do not observe changes to instances of this class. They expect
 *              an NSArray of this class for which they will respond to changes.
 *              Do not modify instances of this class once assigned to your
 *              instance of Fragaria; instead assign a new copy of your
 *              syntaxErrors array.
 */

@interface SMLSyntaxError : NSObject


#pragma mark - Retrieving Default Images
/// @name Retrieving Default Images


/** The image which will be set on a SMLSyntaxError instance when the given
 *  warningLevel is set.
 *  @discussion The default images are stored in and loaded from the
 *              framework bundle automatically.
 *  @param level indicates the level (severity) of this error. */
+ (NSImage *)defaultImageForWarningLevel:(float)level;


#pragma mark - Creating Instances
/// @name Creating Instances


/** Returns an SMLSyntaxError with its properties set as indicated by the
 *  given dictionary.
 *  @param dictionary A dictionary where each key is the property name. */
+ (instancetype)errorWithDictionary:(NSDictionary *)dictionary;

/** Return an SMLSyntaxError with the specified properties.
 *  @discussion The created error's character and length properties will be set
 *              to 1 and 0 respectively, and the error will not be hidden.
 *  @param desc The description of the error.
 *  @param level The error's warning level.
 *  @param line The line where the error appears. */
+ (instancetype)errorWithDescription:(NSString *)desc ofLevel:(float)level
                              atLine:(NSUInteger)line;

/** Returns an SMLSyntaxError initialized as specified by the given dictionary.
 *  @param dictionary A dictionary where each key is a property name. */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


#pragma mark - Getting and Setting Error Properties
/// @name Getting and Setting Error Properties


/** The line at which this error occurs.
 *  @discussion The line number is always one-based.*/
@property NSUInteger line;
/** The one-based character position at which this error begins. */
@property NSUInteger character;
/** The length of this error, in characters. */
@property NSUInteger length;
/** A description for this error. */
@property NSString *errorDescription;
/** Indicates whether or not this error is hidden from display. */
@property BOOL hidden;

/** The color to use to highlight the line where this error is placed.
 *  @discussion This property can be overridden by other errors on the same
 *              line with equal or higher warningLevel. */
@property NSColor *errorLineHighlightColor;
/** The warning level or severity of this error. 
 *  @discussion This property will also change warningImage if warningImage
 *              has never been set manually. */
@property (nonatomic) float warningLevel;

/** An image that should be associated with this syntax error.
 *  @discussion If you never set this property, it will be automatically set
 *              to a default image every time warningLevel is set. As soon
 *              as you set an image to this property manually, this behavior
 *              will stop. */
@property (nonatomic) NSImage *warningImage;


@end
