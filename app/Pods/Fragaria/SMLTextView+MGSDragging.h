//
//  SMLTextView+JSDExtension.h
//  Fragaria
//
//  File created by Jim Derry on 2015/02/07.
//
//  - Extends SMLTextView to use its delegate to pass off its <NSDraggingDestination> methods to the delegate.
//  - Implements the required <NSDraggingDestination> protocol classes, passing them on to the delegate.
//

#import "SMLTextView.h"


@interface SMLTextView (MGSDragging)

@end
