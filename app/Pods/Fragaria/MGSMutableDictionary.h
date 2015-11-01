//
//  MGSMutableDictionary.h
//  Fragaria
//
//  Created by Jim Derry on 3/14/15.
//
//

#import <Foundation/Foundation.h>

@class MGSUserDefaultsController;


/**
 *  An NSMutableDictionary subclass implemented by MGSUserDefaultsController so
 *  that it can persist keys in the user defaults system, if desired.
 */
@interface MGSMutableDictionary : NSMutableDictionary

/**
 *  A convenience initializer to assign the controller and dictionary contents.
 *  @param controller The instance of MGSUserDefaultsController owning this dictionary.
 *  @param dictionary An initial dictionary of values to populate this dictionary.
 **/
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary;

/** A reference to the controller that owns an instance of this class. */
@property (weak) MGSUserDefaultsController *controller;

@end
