//
//  MGSSyntaxDefinition.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 03/02/15.
//
//

#import "MGSSyntaxDefinition.h"


// syntax definition dictionary keys

NSString *SMLSyntaxDefinitionAllowSyntaxColouring = @"allowSyntaxColouring";

NSString *SMLSyntaxDefinitionAlternativeNumberRegex = @"numberDefinition";

NSString *SMLSyntaxDefinitionKeywords = @"keywords";
NSString *SMLSyntaxDefinitionAutocompleteWords = @"autocompleteWords";
NSString *SMLSyntaxDefinitionRecolourKeywordIfAlreadyColoured = @"recolourKeywordIfAlreadyColoured";
NSString *SMLSyntaxDefinitionKeywordsCaseSensitive = @"keywordsCaseSensitive";

NSString *SMLSyntaxDefinitionBeginCommand = @"beginCommand";
NSString *SMLSyntaxDefinitionEndCommand = @"endCommand";

NSString *SMLSyntaxDefinitionInstructions = @"instructions";
NSString *SMLSyntaxDefinitionBeginInstruction = @"beginInstruction";
NSString *SMLSyntaxDefinitionEndInstruction = @"endInstruction";

NSString *SMLSyntaxDefinitionVariableRegex = @"variableRegex";
NSString *SMLSyntaxDefinitionBeginVariable = @"beginVariable";
NSString *SMLSyntaxDefinitionEndVariable = @"endVariable";

NSString *SMLSyntaxDefinitionFirstString = @"firstString";
NSString *SMLSyntaxDefinitionSecondString = @"secondString";

NSString *SMLSyntaxDefinitionSingleLineCommentRegex = @"singleLineCommentRegex";
NSString *SMLSyntaxDefinitionFirstSingleLineComment = @"firstSingleLineComment";
NSString *SMLSyntaxDefinitionSecondSingleLineComment = @"secondSingleLineComment";
NSString *SMLSyntaxDefinitionBeginFirstMultiLineComment = @"beginFirstMultiLineComment";
NSString *SMLSyntaxDefinitionEndFirstMultiLineComment = @"endFirstMultiLineComment";
NSString *SMLSyntaxDefinitionBeginSecondMultiLineComment = @"beginSecondMultiLineComment";
NSString *SMLSyntaxDefinitionEndSecondMultiLineComment = @"endSecondMultiLineComment";

NSString *SMLSyntaxDefinitionExcludeFromKeywordStartCharacterSet = @"excludeFromKeywordStartCharacterSet";
NSString *SMLSyntaxDefinitionExcludeFromKeywordEndCharacterSet = @"excludeFromKeywordEndCharacterSet";
NSString *SMLSyntaxDefinitionIncludeInKeywordStartCharacterSet = @"includeInKeywordStartCharacterSet";
NSString *SMLSyntaxDefinitionIncludeInKeywordEndCharacterSet = @"includeInKeywordEndCharacterSet";



@implementation MGSSyntaxDefinition {
    NSArray *sortedAutocompleteWords;
}


- (instancetype)initFromSyntaxDictionary:(NSDictionary *)syntaxDictionary name:(NSString *)name
{
    self = [super init];
    [self setDefaults];

    _syntaxDictionary = syntaxDictionary;
    _name = name;
    
    // If the plist file is malformed be sure to set the values to something
    
    // keywords case sensitive
    id value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionKeywordsCaseSensitive];
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
        _keywordsCaseSensitive = [value boolValue];
    }
    
    // syntax colouring
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionAllowSyntaxColouring];
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
        _syntaxDefinitionAllowsColouring = [value boolValue];
    } else {
        // default to YES
        _syntaxDefinitionAllowsColouring = YES;
    }
    
    // number regex
    value = [syntaxDictionary objectForKey:SMLSyntaxDefinitionAlternativeNumberRegex];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _numberDefinition = value;
    }
    
    // keywords
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionKeywords];
    if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"NSArray expected");
        _keywords = [self caseAdjustedSetFromKeywordArray:value];
    }
    
    // autocomplete words
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionAutocompleteWords];
    if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"NSArray expected");
        _autocompleteWords = [[NSSet alloc] initWithArray:value];
    }
    
    // recolour keywords
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionRecolourKeywordIfAlreadyColoured];
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"NSNumber expected");
        _recolourKeywordIfAlreadyColoured = [value boolValue];
    }
    
    // begin command
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginCommand];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _beginCommand = value;
    } else {
        _beginCommand = @"";
    }
    
    // end command
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndCommand];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _endCommand = value;
    } else {
        _endCommand = @"";
    }
    
    // instructions
    value = [syntaxDictionary objectForKey:SMLSyntaxDefinitionInstructions];
    if (value) {
        NSAssert([value isKindOfClass:[NSArray class]], @"NSArray expected");
        _instructions = [self caseAdjustedSetFromKeywordArray:value];
    } else {
        // begin instruction
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginInstruction];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            _beginInstruction = value;
        } else {
            _beginInstruction = @"";
        }
        
        // end instruction
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndInstruction];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            _endInstruction = value;
        } else {
            _endInstruction = @"";
        }
    }
    
    // variables
    value = [syntaxDictionary objectForKey:SMLSyntaxDefinitionVariableRegex];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _variableRegex = value;
    } else {
        // begin variable
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginVariable];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            _beginVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:value];
        } else {
            _beginVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
        }
        
        // end variable
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndVariable];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            _endVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:value];
        } else {
            _endVariableCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
        }
    }
    
    // first string
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionFirstString];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _firstString = value;
    } else {
        _firstString = @"";
    }
    
    // second string
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionSecondString];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _secondString = value;
    } else {
        _secondString = @"";
    }
    
    value = [syntaxDictionary objectForKey:SMLSyntaxDefinitionSingleLineCommentRegex];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        _singleLineCommentRegex = value;
    } else {
        _singleLineComments = [NSMutableArray arrayWithCapacity:2];
        
        // first single line comment
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionFirstSingleLineComment];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            if (![value isEqual:@""])
                [_singleLineComments addObject:value];
        }
        
        // second single line comment
        value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionSecondSingleLineComment];
        if (value) {
            NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
            if (![value isEqual:@""])
                [_singleLineComments addObject:value];
        }
    }
    
    _multiLineComments = [NSMutableArray arrayWithCapacity:2];
    id pairedValue;
    
    // first multi line comment
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginFirstMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        if (![value isEqual:@""]) {
            pairedValue = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndFirstMultiLineComment];
            NSAssert([pairedValue isKindOfClass:[NSString class]], @"NSString expected");
            if (![pairedValue isEqual:@""])
                [_multiLineComments addObject:@[value, pairedValue]];
        }
    }
    
    // second multi line comment
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionBeginSecondMultiLineComment];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        if (![value isEqual:@""]) {
            pairedValue = [syntaxDictionary valueForKey:SMLSyntaxDefinitionEndSecondMultiLineComment];
            NSAssert([pairedValue isKindOfClass:[NSString class]], @"NSString expected");
            if (![pairedValue isEqual:@""])
                [_multiLineComments addObject:@[value, pairedValue]];
        }
    }
    
    // exclude characters from keyword start character set
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionExcludeFromKeywordStartCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        NSMutableCharacterSet *temporaryCharacterSet = [self.keywordStartCharacterSet mutableCopy];
        [temporaryCharacterSet removeCharactersInString:value];
        _keywordStartCharacterSet = [temporaryCharacterSet copy];
    }
    
    // exclude characters from keyword end character set
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionExcludeFromKeywordEndCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        NSMutableCharacterSet *temporaryCharacterSet = [self.keywordEndCharacterSet mutableCopy];
        [temporaryCharacterSet removeCharactersInString:value];
        _keywordEndCharacterSet = [temporaryCharacterSet copy];
    }
    
    // include characters in keyword start character set
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionIncludeInKeywordStartCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        NSMutableCharacterSet *temporaryCharacterSet = [self.keywordStartCharacterSet mutableCopy];
        [temporaryCharacterSet addCharactersInString:value];
        _keywordStartCharacterSet = [temporaryCharacterSet copy];
    }
    
    // include characters in keyword end character set
    value = [syntaxDictionary valueForKey:SMLSyntaxDefinitionIncludeInKeywordEndCharacterSet];
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"NSString expected");
        NSMutableCharacterSet *temporaryCharacterSet = [self.keywordEndCharacterSet mutableCopy];
        [temporaryCharacterSet addCharactersInString:value];
        _keywordEndCharacterSet = [temporaryCharacterSet copy];
    }
    
    return self;
}


- (void)setDefaults {
    // name character set
    NSMutableCharacterSet *temporaryCharacterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [temporaryCharacterSet addCharactersInString:@"_"];
    _nameCharacterSet = [temporaryCharacterSet copy];
    
    // keyword start character set
    temporaryCharacterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [temporaryCharacterSet addCharactersInString:@"_:@#"];
    _keywordStartCharacterSet = [temporaryCharacterSet copy];
    
    // keyword end character set
    // see http://www.fileformat.info/info/unicode/category/index.htm for categories that make up the sets
    temporaryCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    [temporaryCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [temporaryCharacterSet removeCharactersInString:@"_-"]; // common separators in variable names
    _keywordEndCharacterSet = [temporaryCharacterSet copy];
    
    // number character set
    _numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    _decimalPointCharacter = [@"." characterAtIndex:0];
    
    // attributes character set
    temporaryCharacterSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [temporaryCharacterSet addCharactersInString:@" -"]; // If there are two spaces before an attribute
    _attributesCharacterSet = [temporaryCharacterSet copy];
}


- (NSSet*)caseAdjustedSetFromKeywordArray:(NSArray*)array
{
    if (self.keywordsCaseSensitive == NO) {
        NSMutableArray *lowerCaseKeywords = [[NSMutableArray alloc] init];
        for (id item in array) {
            [lowerCaseKeywords addObject:[item lowercaseString]];
        }
        return [NSSet setWithArray:lowerCaseKeywords];
    }
    return [NSSet setWithArray:array];
}


- (NSArray*)completions
{
    if (!sortedAutocompleteWords) {
        NSArray *tmp;
        
        tmp = [self.autocompleteWords allObjects];
        sortedAutocompleteWords = [tmp sortedArrayUsingSelector:@selector(compare:)];
    }
    return sortedAutocompleteWords;
}


@end
