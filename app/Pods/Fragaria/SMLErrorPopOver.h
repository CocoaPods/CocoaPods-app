//
//  SMLErrorPopOver.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@interface SMLErrorPopOver : NSObject

// Pass an array of strings to this function to open up the popover window. Window will be centered in the view that is passed to this function.
+ (void) showErrorDescriptions:(NSArray*)errors relativeToView:(NSView*) view;

@end
