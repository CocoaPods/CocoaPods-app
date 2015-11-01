//
//  MGSColourSchemeController.h
//  Fragaria
//
//  Created by Jim Derry on 3/16/15.
//
//

#import <Foundation/Foundation.h>

@class MGSPreferencesController;


/**
 *  MGSColourSchemeController manages MGSColourScheme instances for use in
 *  UI applications. Although it's designed for use with the MGSFragariaView
 *  settings panel(s), it should be suitable for use in other classes, too.
 *  As an NSArrayController descendant, it can be instantiated by IB.
 *
 *  MGSColourSchemeController doesn't pretend to know anything about your
 *  views or make assumptions about property names. All observing and setting
 *  is performed via the view's objectController instance (which is the
 *  controller for the model object instance MGSUserDefaults controller). Make
 *  sure an instance of this class in IB has its `objectController` outlet
 *  connected to the same objectController that all properties are connected to.
 *
 *  Schemes are loaded first from the framework bundle, then the application
 *  bundle, then finally from the application's Application Support folder.
 *  Subsequent schemes with the same displayName replace schemes loaded
 *  earlier, giving you the chance to modify them without modifying the
 *  framework bundle.
 *
 *  No part of Fragaria saves the scheme name. Consequently the colour scheme
 *  controller looks for a matching named scheme for the current colour
 *  settings. Two schemes with otherwise identical settings will result in the
 *  first scheme in your locality's sort order to be detected.
 *
 *  Schemes are saved in the application's Application Support/Colour Schemes
 *  directory, and only those schemes can be deleted.
 *
 *  To create a new scheme, you have to modify an already existing scheme, at
 *  which point the name of the scheme changes to Custom Settings. This
 *  scheme can then be saved when ready.
 *
 *  This makes it impossible to modify existing schemes per se, however the
 *  workaround is to modify the existing scheme and save it with a new name,
 *  The previous version can then be selected and deleted. This is consistent
 *  with the behaviour of many other text editors.
 **/
@interface MGSColourSchemeController : NSArrayController


#pragma mark - IBOutlet Properties - Controls
/// @name IBOutlet Properties - Controls

/** A reference to the MGSUserDefaultsController for the view.
 *  @discussion This controller needs to know where the model controller for
 *      your view is. Your view should access MGSFragariaView properties with
 *      an NSObjectController. This property is a reference to that
 *      controller. */
@property (nonatomic, assign) IBOutlet NSObjectController *objectController;

/** A popup list that provides the current list of available schemes. */
@property (nonatomic, assign) IBOutlet NSPopUpButton *schemeMenu;

/** A button used to save or delete a scheme.
 *  @discussion Its action should be set to -addDeleteButtonAction:
 *  You can get a suitable title and enabled state from buttonSaveDeleteTitle
 *  and buttonSaveDeleteEnabled respectively. */
@property (nonatomic, assign) IBOutlet NSButton *schemeSaveDeleteButton;

/** A reference to the parent view. You must set this in IB otherwise
 *  save and delete dialogues will not attach as sheet to the window. */
@property (nonatomic, assign) IBOutlet NSView *parentView;


#pragma mark - Properties - Bindable for UI Use
/// @name Properties - Bindable for UI Use

/** The current correct state of a save/delete button. Bind the button to
 this property in interface builder to ensure its correct state. */
@property (nonatomic, assign, readonly) BOOL buttonSaveDeleteEnabled;

/** A title for the save/delete button. Bind the button to this property
 in interface builder for automatic localized button name. */
@property (nonatomic, assign, readonly) NSString *buttonSaveDeleteTitle;


#pragma mark - Actions
/// @name Actions

/** The add/delete button action.
 *  @discussion When your button's title is bound to buttonSaveDelete title,
 *  the title will update dynamically to reflect the correct action.
 *  @param sender The object that sent the action. */
- (IBAction)addDeleteButtonAction:(id)sender;



@end
