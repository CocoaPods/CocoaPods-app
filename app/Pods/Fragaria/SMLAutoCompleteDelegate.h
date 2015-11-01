//
//  SMLAutoCompleteDelegate.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/12/13.
//
//

#import <Foundation/Foundation.h>


/**
 *  The SMLAutoCompleteDelegate defines an interface for allowing a delegate to
 *  return a list of suitable autocomplete choices.
 **/
@protocol SMLAutoCompleteDelegate <NSObject>

- (NSArray*) completions;   ///< A dictionary of words that can be used for autocompletion.

@end
