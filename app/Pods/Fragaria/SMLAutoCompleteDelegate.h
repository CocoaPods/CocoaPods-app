//
//  SMLAutoCompleteDelegate.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/12/13.
//
//

#import <Foundation/Foundation.h>

@protocol SMLAutoCompleteDelegate <NSObject>

- (NSArray*) completions;

@end
