//
//  MGSSyntaxDefinition.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 03/02/15.
//
//

#import <Foundation/Foundation.h>
#import "SMLAutoCompleteDelegate.h"


@class MGSFragariaView;


/** An MGSSyntaxDefinition is a model object that describes how
 *  SMLSyntaxColouring should behave. Also, it provides information on the
 *  current syntax definition to allow editing functions such as commenting
 *  and un-commenting. */

@interface MGSSyntaxDefinition : NSObject <SMLAutoCompleteDelegate>


/**  Determines if colouring for this syntax definition is allowed. */
@property (readonly) BOOL syntaxDefinitionAllowsColouring;

/**  Secondary string delimiter. */
@property (readonly) NSString *secondString;
/**  Primary string delimiter. */
@property (readonly) NSString *firstString;

/**  Delimiter for the start of a command. */
@property (readonly) NSString *beginCommand;
/**  Delimiter for the end of a command. */
@property (readonly) NSString *endCommand;

/** A set of words that are considered keywords. If keywordsCaseSensitive is
 *  YES, this set will contain lowercase strings only. */
@property (readonly) NSSet *keywords;
/** A set of words that can be used for autocompletion. If
 *  keywordsCaseSensitive is YES, this set will contain lowercase strings
 *  only. */
@property (readonly) NSSet *autocompleteWords;
/** A set of all the characters that can be at the beginning of a keyword.
 *  By default, this set contains all the latin letters (uppercase and
 *  lowercase) plus the characters _, :, @, #, and comma. */
@property (readonly) NSCharacterSet *keywordStartCharacterSet;
/** A set of all the characters that can be at the end of a keyword.
 *  By default, this set contains whitespaces, newlines, punctuation and 
 *  symbols, with the exclusion of the characters _ and dash. */
@property (readonly) NSCharacterSet *keywordEndCharacterSet;
/** Indicates if keywords should have higher priority than commands. Set to
 * YES when you want keywords to be nested inside commands. */
@property (readonly) BOOL recolourKeywordIfAlreadyColoured;
/** Indicates whether or not keywords are case-sensitive. */
@property (readonly) BOOL keywordsCaseSensitive;

/** A set of words that are considered instructions. If keywordsCaseSensitive
 *  is YES, this set will contain lowercase strings only.
 *  @discussion If this property is nil, instructions should be detected using
 *       beginInstruction and endInstruction, otherwise they should be
 *       ignored. */
@property (readonly) NSSet *instructions;
/**  Delimiter for the start of an instruction iff instructions == nil. */
@property (readonly) NSString *beginInstruction;
/**  Delimiter for the end of an instruction iff instructions == nil. */
@property (readonly) NSString *endInstruction;

/** A regular expression that matches a variable.
 *  @discussion This property supersedes beginVariableCharacterSet and
 *       endVariableCharacterSet. If this property is nil, a syntax
 *       colourer should use these properties instead, otherwise they
 *       should be ignored. */
@property (readonly) NSString *variableRegex;
/**  Characters that may start a variable. */
@property (readonly) NSCharacterSet *beginVariableCharacterSet;
/**  Characters that may terminate a variable. */
@property (readonly) NSCharacterSet *endVariableCharacterSet;

/** A regular expression that matches a single line comment.
 *  @discussion This property supersedes singleLineComments. If this property
 *      is nil, a syntax colourer should use singleLineComments instead,
 *      otherwise it is ignored. */
@property (readonly) NSString *singleLineCommentRegex;
/** An array of strings that should mark the beginning of a single-line comment.
 *  This kind of comments extends from the characters that mark its start
 *  to the end of its line. */
@property (readonly) NSMutableArray *singleLineComments;
/** An array of arrays containing an opening and a closing string for each
 *  multiline comment kind. */
@property (readonly) NSMutableArray *multiLineComments;

/** Characters to be coloured as attributes. Fragaria colours as "attributes"
 *  structures that consist of one or more alphanumeric characters followed by
 *  an equal sign, like 56=. In this example, only 56 is considered an
 *  attribute and will be coloured as such. */
@property (readonly) NSCharacterSet *attributesCharacterSet;

/** A regular expression that matches numbers.
 *  @discussion This property supersedes numberCharacterSet, nameCharacterSet
 *      and decimalPointCharacter. If this property is nil, a syntax
 *      colourer should use those properties instead, otherwise they are
 *      ignored. */
@property (readonly) NSString *numberDefinition;
/** Characters to be coloured as numbers, if numberDefinition is nil. This
 *  includes eventual decimal separators. */
@property (readonly) NSCharacterSet *numberCharacterSet;
/** Characters that should not precede a number for it to be coloured.
 *  @discussion This property has no effect if numberDefinition is non-nil. */
@property (readonly) NSCharacterSet *nameCharacterSet;
/** A character that will not be coloured as a number - even if included in
 *  numberCharacterSet - if it is the last character of the number.
 *  @discussion This property has no effect if numberDefinition is non-nil. */
@property (readonly) unichar decimalPointCharacter;


/** A dictionary which describes this syntax definition. This method returns
 *  a representation of this syntax definition suitable as a parameter to
 *  -initFromSyntaxDictionary: to make a syntax definition equal to this
 *  one. */
@property (readonly) NSDictionary *syntaxDictionary;
/** A name associated with this syntax definition. Might be nil. */
@property (readonly) NSString *name;


/** Designated initializer.
 *  Initializes a new syntax definition object from a dictionary object,
 *  usually read from a plist in the framework bundle.
 *  @param syntaxDictionary A dictionary representation of the plist file that
 *                          defines the syntax.
 *  @param name An optional name for this syntax dictionary. */
- (instancetype)initFromSyntaxDictionary:(NSDictionary *)syntaxDictionary name:(NSString*)name;

/** Autocomplete delegate main method. Returns a lexicographically ordered
 *  array of the objects in the autocompleteWords set. */
- (NSArray*)completions;


@end


