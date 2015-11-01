//
//  MGSUserDefaultsController.h
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import <Foundation/Foundation.h>
#import "MGSFragariaView+Definitions.h"
#import "MGSUserDefaultsControllerProtocol.h"

@class MGSFragariaView;


/**
 *  MGSUserDefaultsController and its related class are alternatives to
 *  NSUserDefaults and NSUserDefaultsController, which support being able to
 *  manage multiple sets of the same defaults keys for multiple instances of an
 *  object. This can be particularly useful when binding to user-interface
 *  controls.
 *
 *  In order to support shared defaults, i.e., a default that serves as a master
 *  for multiple instances, there's also a global default. For example if you
 *  wish to ensure that multiple text views' `backgroundColor` is shared, you
 *  can specify that that `backgroundColor` is a global property.
 *
 *  Where persistent defaults are stored is implementation-dependent. This
 *  implementation uses NSUserDefaults as its backend, but you shouldn't use
 *  NSUserDefaults to access them.
 */

@interface MGSUserDefaultsController : NSObject <MGSUserDefaultsController>


#pragma mark - Retrieving shared controllers
/// @name Retrieving shared controllers


/** Returns the shared controller for `groupID`.
 *  @discussion All instances of MGSFragariaView that you wish to manage with
 *      this toolset must belong to at least one `groupID`. Every instance of
 *      MGSFragariaView within the same `groupID` is affected.
 *  @param groupID An user defaults group identifier. */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID;


/** Provides the shared controller for global defaults.
 *  @discussion This controller manages properties that you wish to remain
 *      common among all groups in your application. Every instance of
 *      MGSFragariaView that belongs to a `groupID` is affected. */
+ (instancetype)sharedController;


#pragma mark - Handling managed properties
/// @name Handling managed properties


/** Indicates if properties are stored in user defaults and persist
 *  between launches. */
@property (nonatomic, assign, getter=isPersistent) BOOL persistent;


/** The set of property names managed by this class. 
 *  @discussion This is initially set to all available properties of
 *      MGSFragariaView for the global controller, and to an empty set for all
 *      the other controllers.
 *
 *      This property is meant to be seldom changed. When setting this property
 *      on a local controller, the properties are automatically removed from
 *      the responsibility of the global controller. When setting this property
 *      on a global controller, if the property set contains any property
 *      already managed by any local controller, an exception will be raised.*/
@property (nonatomic, strong) NSSet *managedProperties;


/** Returns a key value coding compliant object that is used to access the user
 *  default properties.
 *  @discussion Use only KVC setValue:forKey: and valueForKey: with this
 *      object. In general you have no reason to manually manipulate values
 *      within this structure. Simply set MGSFragariaView properties instead.*/
@property (nonatomic,strong, readonly) id values;


#pragma mark - Handling managed objects
/// @name Handling managed objects


/** Specifies the instances of MGSFragaria whose properties are managed by
 *  this controller.
 *  @discussion The shared controller returns the union set of the managed
 *      instances across all controllers, including the managed instances
 *      registered to itself by means of -addFragariaToManagedSet: and
 *      -removeFragariaFromManagedSet:.*/
@property (nonatomic,strong, readonly) NSSet *managedInstances;

/** Adds an instance of MGSFragariaView to the set of managed instances for
 *  this controller.
 *  @discussion If the same instance is already managed by another controller,
 *      an exception will be raised.
 *  @param fragaria The instance of MGSFragariaView to be added. */
- (void)addFragariaToManagedSet:(MGSFragariaView *)fragaria;

/** Removes an instance of MGSFragariaView to the set of managed instances for
 *  this controller.
 *  @discussion If the specified instance of Fragaria is not registered to this
 *      controller, nothing happens.
 *  @param fragaria The instance of MGSFragariaView to be removed. */
- (void)removeFragariaFromManagedSet:(MGSFragariaView *)fragaria;


#pragma mark - Getting the group identifier
/// @name Getting the group identifier


/** Returns the unique identifier for this controller's group. */
@property (nonatomic,strong,readonly) NSString *groupID;


@end
