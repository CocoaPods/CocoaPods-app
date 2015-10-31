//
//  SMLTextViewPrivate.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 26/02/15.
//
//

#import <Cocoa/Cocoa.h>
#import "SMLTextView.h"


@class MGSExtraInterfaceController;
@class SMLSyntaxColouring;
@class SMLLayoutManager;


@interface SMLTextView ()


/// @name Private properties


/** The controller which manages the accessory user interface for this text
 * view. */
@property (readonly) MGSExtraInterfaceController *interfaceController;

/** Instances of this class will perform syntax highlighting in text views. */
@property (readonly) SMLSyntaxColouring *syntaxColouring;

/** SMLTextView's layout manager is an SMLLayoutManager internally, but that
 * class is not exposed. */
@property (assign, readonly) SMLLayoutManager *layoutManager;


@end
