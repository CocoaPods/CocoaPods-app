//
//  MGSUserDefaultsControllerProtocol.h
//  Fragaria
//
//  Created by Jim Derry on 3/24/15.
//
//
#include <Cocoa/Cocoa.h>


/**
 *  The MGSUserDefaultsController protocol defines the properties and methods
 *  that are required for objects to be used with the Defaults Coordinator
 *  system user interface objects.
 *
 *  @discussion Both MGSUserDefaultsController (class) and
 *      MGSHybridUserDefaultsController conform to this protocol and can be
 *      used interchangeably.
 */

@protocol MGSUserDefaultsController <NSObject>


#pragma mark - Required Properties and Methods
/// @name Required Properties and Methods
@required


/** The groupID uniquely identifies the preferences that
 *  are managed by instances of this controller. */
@property (nonatomic,strong,readonly) NSString *groupID;


/** Indicates the instances of MGSFragaria whose properties are
 *  managed by an instance of this controller. */
@property (nonatomic,strong,readonly) NSSet *managedInstances;


/** Indicates a set of NSString indicating the name of every property
 *  that is to be managed by this instance of this class. */
@property (nonatomic,strong,readonly) NSSet *managedProperties;


/** Provides KVO-compatible structure for use with NSObjectController.
 *  @discussion Use only KVC setValue:forKey: and valueForKey: with this
 *      object. In general you have no reason to manually manipulate values
 *      with this structure. Simply set MGSFragariaView properties instead. */
@property (nonatomic,strong,readonly) id values;


@end

