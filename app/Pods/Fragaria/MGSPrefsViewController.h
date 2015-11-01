//
//  MGSPrefsViewController.h
//  Fragaria
//
//  Created by Jim Derry on 3/15/15.
//
//

#import <Cocoa/Cocoa.h>
#import "MGSUserDefaultsControllerProtocol.h"



/** 
 *  MGSPrefsViewController is an abstract class for other MGSPrefsViewController
 *  classes. It is not to be used directly.
 *  @see MGSPrefsEditorPropertiesViewController
 *  @see MGSPrefsColourPropertiesViewController 
 */

@interface MGSPrefsViewController : NSViewController


/** The NSObjectController that the UI elements are bound to. Its contentObject
 *  is an instance of MGSUserDefaultsController, and should be set in IB.  */
@property (nonatomic, weak) IBOutlet NSObjectController *objectController;

/** A reference to the properties controller that is the model for this view. */
@property (nonatomic, weak) id <MGSUserDefaultsController> userDefaultsController;


/** An unique identifier for the preference panel. */
@property (nonatomic, readonly) NSString *identifier;

/** An icon for this preference panel to be used in an NSToolbar. */
@property (nonatomic, readonly) NSImage *toolbarItemImage;

/** A string to be used as a title to this preference panel. */
@property (nonatomic, readonly) NSString *toolbarItemLabel;


/** Returns whether or not a property is a managed property. This is a KVC
 *  structure that returns @(YES) or @(NO) for keyPaths in the form of
 *  this_controller.managedProperties.propertyName.
 *  @discussion Useful for user interface enabled bindings to disable elements
 *      that the userDefaultsController doesn't manage. */
@property (nonatomic, assign, readonly) id managedProperties;


/** Returns whether or not a property is a managed global property. This is a 
 *  KVC structure that returns @(YES) or @(NO) for keyPaths in the form of
 *  this_controller.managedProperties.propertyName.
 *  @discussion Useful for user interface enabled bindings to style elements
 *      that a hybrid userDefaultsController manages. */
@property (nonatomic, assign, readonly) id managedGlobalProperties;


/** Bindable property indicating whether or not the scheme menu should be
 *  enabled. If the instance does not have available every property for a
 *  scheme, then using the scheme selector can be quite messy. */
@property (nonatomic, assign, readonly) BOOL areAllColourPropertiesAvailable;


/** Specifies whether or not to stylize item labels for items that are
 *  managed by the global sharedUserDefaultsController. When YES, boolean
 *  properties in Interface Builder (such as Font Bold) that are bound to
 *  managedGlobalProperties will receive a non-nil value of YES or NO. */
@property (nonatomic, assign) BOOL stylizeGlobalProperties;

/** Indicates whether or not panels that have no eligible properties should
 *  be hidden. */
@property (nonatomic, assign) BOOL hidesUselessPanels;


/** A dictionary which pairs, for each panel of this preference view,
 *  the NSSet of properties it manages. If a set for a given panel is missing
 *  from the dictionary, that panel is always shown. 
 *  @discussion Since NSView does not conform to NSCoding, the keys in the
 *       dictionary must be the KVO key for a property of self used
 *       to access that view. This dictionary is used to determine
 *       which panels are to be hidden or not. */
- (NSDictionary *)propertiesForPanelSubviews;

/** The ordered list of the keys for this preference view's panels. The
 *  keys must be in the same order that panels are to be shown in the view.
 *  @discussion The final location of the panels is determined 
 *      at runtime depending on which views are to be hidden or not.
 *      this array determines in which order the panels are to be
 *      placed in the view. */
- (NSArray *)keysForPanelSubviews;


@end
