//
//  MGSUserDefaults.h
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import <Foundation/Foundation.h>
#import "MGSFragariaView+Definitions.h"


/** This macro defines the groupID that should correspond to the global group
 *  for MGSUserDefaults and, by extension, MGSUserDefaultsController. */
#define MGSUSERDEFAULTS_GLOBAL_ID @"Global"


/**
 *  MGSUserDefaults is the NSUserDefaults internal replacement for use by
 *  MGSUserDefaultsController. The main characteristic versus NSUserDefaults
 *  is that it is assigned a `groupID` that is used to group multiple sets
 *  of the same default together in a manner that is transparent to the
 *  developer.
 *
 *  In general user defaults managed by this class are not compatible with
 *  NSUserDefaults. It's certainly possible to use NSUserDefaults to change
 *  or read managed keys, but there's not much point.
 */
@interface MGSUserDefaults : NSUserDefaults


#pragma mark - Class Methods - Singleton Controllers

/**
 *  Provides a shared controller for `groupID`.
 *  @param groupID Indicates the identifier for this group
 *  of user defaults.
 **/
+ (instancetype)sharedUserDefaultsForGroupID:(NSString *)groupID;


/**
 *  Provides the shared controller for global defaults.
 **/
+ (instancetype)sharedUserDefaults;


#pragma mark - Instance Methods

/**
 *  Registers user defaults for this instance.
 *  @param registrationDictionary The dictionary of values to register.
 **/
- (void)registerDefaults:(NSDictionary *)registrationDictionary;


#pragma mark - Properties

/**
 *  Returns the groupID of this instance of the controller.
 **/
@property (nonatomic,strong,readonly) NSString *groupID;

@end
